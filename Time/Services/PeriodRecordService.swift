//
//  PeriodRecordService.swift
//  Time
//
//  Created by A on 07/08/2024.
//

import Foundation
import SwiftData
import Collections

@Observable
class PeriodRecordService {

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
    
    private func getFetchDescriptor(predicate: Predicate<PeriodRecord>) -> FetchDescriptor<PeriodRecord> {
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.propertiesToFetch = [\.startTime, \.endTime]
        return descriptor
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
            guard let dailyPeriods = try? context.fetch(getFetchDescriptor(predicate: PeriodRecord.predicateDailyApproximation)) else {
                return 0
            }
            accumulatedSecondsDaily = sumPeriods(periods: dailyPeriods.filter(\.isStopped), component: .day)
        }
        return sumPeriods(periods: activePeriods.map(\.value), component: .day) + (accumulatedSecondsDaily ?? 0)
    }
    
    var totalSecondsWeekly: Double {
        if accumulatedSecondsWeekly == nil {
            guard let weeklyPeriods = try? context.fetch(getFetchDescriptor(predicate: PeriodRecord.predicateWeeklyApproximation)) else {
                return 0
            }
            accumulatedSecondsWeekly = sumPeriods(periods: weeklyPeriods.filter(\.isStopped), component: .weekOfYear)
        }
        return sumPeriods(periods: activePeriods.map(\.value), component: .weekOfYear) + (accumulatedSecondsWeekly ?? 0)
    }
    
    private func sumPeriods(periods: [PeriodRecord], component: Calendar.Component) -> Double {
        let result =  periods.reduce(0) { result, period in
            
            guard let (start, end) = clipPeriod(period, into: component) else {
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
    
    private func clipPeriod(_ period: PeriodRecord, into component: Calendar.Component, anchor: Date = .now) -> (Date, Date)? {
        
        guard var start = period.startTime else { // we must have a start time
            print("error") // TODO: error logging
            return nil
        }
        
        let now = Date.now
        
        guard let interval = calendar.dateInterval(of: component, for: now) else {
            print("error") // TODO: error logging
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
