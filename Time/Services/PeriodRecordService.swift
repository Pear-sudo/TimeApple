//
//  PeriodRecordService.swift
//  Time
//
//  Created by A on 07/08/2024.
//

import Foundation
import SwiftData
import Collections
import OSLog

@Observable
class PeriodRecordService {
    @ObservationIgnored
    private let logger = Logger(subsystem: "cyou.b612.model.service", category: "period_record")

    @ObservationIgnored
    private let calendar = Calendar.autoupdatingCurrent
    @ObservationIgnored
    private var context: ModelContext
    private(set) var activePeriods: OrderedDictionary<UUID, PeriodRecord> = [:]
    
    init(context: ModelContext) {
        self.context = context
        if let unfinishedPeriods = try? context.fetch(FetchDescriptor<PeriodRecord>(
            predicate: #Predicate<PeriodRecord> { period in
                !(period.startTime != nil && period.endTime != nil)
            })) {
            var activePeriods: OrderedDictionary<UUID, PeriodRecord> = [:]
            unfinishedPeriods.forEach { period in
                if period.startTime !=  nil {
                    if activePeriods[period.project.id] != nil {
                        print("abnormal period detected, removing...")
                        context.delete(period)
                    } else {
                        activePeriods[period.project.id] = period
                    }
                } else {
                    print("abnormal period detected, removing...")
                    context.delete(period)
                }
            }
            self.activePeriods = activePeriods
        }
    }
    
    subscript(key: ProjectItem) -> PeriodRecord? {
        return activePeriods[key.id]
    }
    
    func start(project: ProjectItem) {
        if activePeriods[project.id] != nil {
            return
        }
        let period = PeriodRecord(project: project)
        context.insert(period)
        period.start()
        
        activePeriods[project.id] = period
    }
    
    func stop(project: ProjectItem) {
        if let period = activePeriods[project.id] {
            period.stop()
            activePeriods[project.id] = nil
            accumulateDaily(period: period)
            accumulateWeekly(period: period)
        }
    }
    
    func hasActivePeriods() -> Bool {
        return !activePeriods.isEmpty
    }
    
    func hasActivePeriods(for project: ProjectItem) -> Bool {
        return activePeriods[project.id] != nil
    }
        
    private func getTimeOnlyFetchDescriptor(predicate: Predicate<PeriodRecord>) -> FetchDescriptor<PeriodRecord> {
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.propertiesToFetch = [\.startTime, \.endTime]
        return descriptor
    }
    
    static private let logger = Logger(subsystem: "cyou.b612.model.service", category: "period_record")
    static private let calendar = Calendar.autoupdatingCurrent
    
    static func getRangedPredicate(start: Date, end: Date, strict: Bool = false, polarize: Bool = true) -> Predicate<PeriodRecord>? {
        var start = start
        var end = end
        if polarize {
            start = calendar.startOfDay(for: start)
            if calendar.compare(end, to: end - 1, toGranularity: .day) == .orderedSame {
                // in case end date is already polarized, that is, it is the very beginning of the next date
                guard let e = calendar.dateInterval(of: .day, for: end)?.end else {
                    logger.error("Calendar cannot return the requested date")
                    return nil
                }
                end = e
            }
        }
        return #Predicate<PeriodRecord> { period in
            if let startTime = period.startTime { // has start time
                if startTime >= start && startTime < end { // started in this interval
                    return true
                }
                else { // start time not in the interval
                    if let endTime = period.endTime { // has end time
                        return endTime > start // the end time is in the interval or at some point later than the interval, if we assume the end is always later than the start, this test is equivalent to startTime < start
                    }
                    else { // does not has end time (active)
                        return startTime < start // started earlier than the interval and is active
                    }
                }
            } else {
                return false // not started
            }
        }
    }
    
    /// https://forums.swift.org/t/lazy-var-on-observable-class/66541/2
    /// private vars are synthesized; since they can compose to public accessors. lazy cannot be transformed due to not being able to synthesize that effect (hence the error). If you need a lazy property you can add the @ObservationIgnored macro on it and the observation system will ignore synthesis for that property.
    @ObservationIgnored
    private var accumulatedSecondsDaily: Double? = nil
    @ObservationIgnored
    private var accumulatedSecondsWeekly: Double? = nil
    
    private func accumulateDaily(period: PeriodRecord) {
        guard accumulatedSecondsDaily != nil else {
            return
        }
        accumulatedSecondsDaily = accumulatedSecondsDaily! + sumPeriods(periods: [period], component: .day)
    }
    
    private func accumulateWeekly(period: PeriodRecord) {
        guard accumulatedSecondsWeekly != nil else {
            return
        }
        accumulatedSecondsWeekly = accumulatedSecondsWeekly! + sumPeriods(periods: [period], component: .weekOfYear)
    }
    
    var totalSecondsDaily: Double {
        if accumulatedSecondsDaily == nil {
            guard let dailyPeriods = try? context.fetch(getTimeOnlyFetchDescriptor(predicate: PeriodRecord.predicateDailyApproximation)) else {
                return 0
            }
            accumulatedSecondsDaily = sumPeriods(periods: dailyPeriods.filter(\.isStopped), component: .day)
        }
        return sumPeriods(periods: activePeriods.map(\.value), component: .day) + (accumulatedSecondsDaily ?? 0)
    }
    
    var totalSecondsWeekly: Double {
        if accumulatedSecondsWeekly == nil {
            guard let weeklyPeriods = try? context.fetch(getTimeOnlyFetchDescriptor(predicate: PeriodRecord.predicateWeeklyApproximation)) else {
                return 0
            }
            accumulatedSecondsWeekly = sumPeriods(periods: weeklyPeriods.filter(\.isStopped), component: .weekOfYear)
        }
        return sumPeriods(periods: activePeriods.map(\.value), component: .weekOfYear) + (accumulatedSecondsWeekly ?? 0)
    }
    
    func getPeriods(`in` component: Calendar.Component, anchor: Date) -> [PeriodRecord] {
        guard let interval = calendar.dateInterval(of: component, for: anchor) else {
            logger.error("Calendar cannot return the requested date")
            return []
        }
        let (start, end) = (interval.start, interval.end)
        return getPeriods(from: start, to: end)
    }
    
    /// fetch all periods within the range, if some periods are spanning across the range boundaries, clip those periods so that the start times and end times of these periods are guaranteed to fall within the range
    func getPeriods(from start: Date, to end: Date) -> [PeriodRecord] {
        guard let predicate = PeriodRecordService.getRangedPredicate(start: start, end: end) else {
            return []
        }
        guard let periods = try? context.fetch(FetchDescriptor(predicate: predicate)) else {
            return []
        }
        return periods
    }
    
    func getDailyPeriods(from: Date, to: Date) -> [PeriodRecord] {
        if from >= to {
            return []
        }
        var periods: [PeriodRecord] = []
        var position = from
        while calendar.compare(position, to: to, toGranularity: .day) != .orderedDescending {
            periods.append(contentsOf: getPeriods(in: .day, anchor: position))
            guard let newPosition = calendar.date(byAdding: .day, value: 1, to: position) else {
                logger.error("Calendar cannot return the requested date")
                break
            }
            position = newPosition
        }
        return periods
    }
    
    private func sumPeriods(periods: [PeriodRecord], component: Calendar.Component) -> Double {
        let result =  periods.reduce(0) { result, period in
            
            guard let (start, end) = clipToDateRange(period, into: component) else {
                return result
            }
            
            let duration = end.timeIntervalSince(start)
            if duration <= 0 {
                return result
            }
            
            return result + duration
        }
        return result
    }
    
    private func clipToDateRange(_ period: PeriodRecord, into component: Calendar.Component, anchor: Date = .now) -> (Date, Date)? {
        
        guard var start = period.startTime else { // we must have a start time
            logger.log("Detected a period without start time.")
            return nil
        }
                
        guard let interval = calendar.dateInterval(of: component, for: anchor) else {
            logger.error("Calendar cannot return the requested date")
            return nil
        }
        let intervalStart = interval.start
        let intervalEnd = interval.end
        
        if start < intervalStart { // start is at the beginning of the interval, end is the beginning of next interval, see apple doc, that's why I use < here and use >= later
            start = intervalStart
        }
        
        var end = period.endTime ?? Date.now // for active period without end
        if end >= intervalEnd {
            end = intervalEnd.addingTimeInterval(-1)
        }
        
        return (start, end)
    }
}
