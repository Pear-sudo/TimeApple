//
//  Record.swift
//  Time
//
//  Created by A on 24/07/2024.
//

import Foundation
import SwiftData
import LoremSwiftum
import GeneralMacro

class PeriodRecordSkeleton {
    
    init(id: UUID = UUID(), creationTime: Date = Date(), startTime: Date? = nil, endTime: Date? = nil, project: ProjectItem, notes: String = "") {
        self.id = id
        self.creationTime = creationTime
        self.startTime = startTime
        self.endTime = endTime
        self.project = project
        self.notes = notes
    }
    
    private(set) var id: UUID = UUID()
    private(set) var creationTime: Date = Date()
    
    var startTime: Date?
    var endTime: Date?
    
    var project: ProjectItem
    var notes: String = ""
    
    init(project: ProjectItem) {
        self.project = project
    }
}

@Model
class PeriodRecord {
        
    @Attribute(originalName: "id")
    private(set) var id: UUID = UUID()
    private(set) var creationTime: Date = Date()
    
    var startTime: Date?
    var endTime: Date?
    
    var project: ProjectItem
    var notes: String = ""
    
    init(project: ProjectItem) {
        self.project = project
    }
    
    var skeleton: PeriodRecordSkeleton {
        get {
            return PeriodRecordSkeleton(
                id: id,
                creationTime: creationTime,
                startTime: startTime,
                endTime: endTime,
                project: project,
                notes: notes
            )
        }
        set {
            self.id = newValue.id
            self.creationTime = newValue.creationTime
            self.startTime = newValue.startTime
            self.endTime = newValue.endTime
            self.project = newValue.project
            self.notes = newValue.notes
        }
    }
    
    static let descriptorRunning: FetchDescriptor<PeriodRecord> = FetchDescriptor<PeriodRecord>(
        predicate: #Predicate { record in
            record.startTime != nil && record.endTime == nil
        },
        sortBy: [
            .init(\.startTime, order: .forward)
        ]
    )
    
    static let descriptorLastStopped: FetchDescriptor<PeriodRecord> = {
        var descriptor = FetchDescriptor<PeriodRecord> (
            predicate: #Predicate { record in
                record.startTime != nil && record.endTime != nil
            },
            sortBy: [
                .init(\.endTime, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }()
}

extension PeriodRecord {
    var duration: Duration? {
        if let startTime = startTime, let endTime = endTime {
            return .seconds(endTime.timeIntervalSince(startTime))
        }
        else {
            return nil
        }
    }
}

extension PeriodRecord {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(creationTime)
        hasher.combine(startTime)
        hasher.combine(endTime)
        hasher.combine(project)
    }
}

extension PeriodRecord {
    func start() {
        let now = Date()
        self.startTime = now
        self.project.accessTime = now
    }
    
    func stop() {
        self.endTime = Date()
    }
}

extension PeriodRecord {
    var isPending: Bool {
        self.startTime == nil && self.endTime == nil
    }
    
    var isRunning: Bool {
        self.startTime != nil && self.endTime == nil
    }
    
    var isStopped: Bool {
        self.startTime != nil && self.endTime != nil
    }
    
    var status: Status {
        if isPending {
            return .pending
        }
        if isRunning {
            return .running
        }
        return .stopped
    }
    
    enum Status {
        case pending, running, stopped
    }
}

extension PeriodRecord {
    static var predicateDailyApproximation: Predicate<PeriodRecord> {
        // fuck swift data framework. do not use ternary operator (I know the doc says you can), and make sure now is a constant. a lot of time is wasted.
        // why constant: to convert type to sql code rather than convert sql data back to type in a predicate !!!
        let calendar = Calendar.autoupdatingCurrent
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.dateInterval(of: .day, for: .now)!.end
        return #Predicate<PeriodRecord> { period in
            if let startTime = period.startTime {
                if startTime >= startOfToday && startTime < endOfToday {
                    return true // started today
                }
                else {
                    if let endTime = period.endTime {
                        return endTime > startOfToday // ended today or ended in the future
                    }
                    else {
                        return true // running/active period
                    }
                }
            } else {
                return false // not started
            }
        }
    }
    static var predicateWeeklyApproximation: Predicate<PeriodRecord> {
        let calendar = Calendar.autoupdatingCurrent
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)!.start
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)!.end
        return #Predicate<PeriodRecord> { period in
            if let startTime = period.startTime {
                if startTime >= startOfWeek && startTime < endOfWeek {
                    return true // started this week
                }
                else {
                    if let endTime = period.endTime {
                        return endTime > startOfWeek // ended in this week or ended in the future
                    }
                    else {
                        return true // running/active period
                    }
                }
            } else {
                return false // not started
            }
        }
    }
}

extension Calendar {
    /// stick to the lib's definition of 'end'
    func endOfDay(for date: Date) -> Date? {
        self.dateInterval(of: .day, for: date)?.end
    }
}

extension PeriodRecord {
    var elapsedTime: String {
        self.startTime?.timeIntervalSinceNowString ?? ""
    }
}

extension Date {
    var timeIntervalSinceNowString: String {
        self.timeIntervalSinceNow.timeIntervalString
    }
}

extension TimeInterval {
    var timeIntervalString: String {
        // DateComponentsFormatter is suitable for simpler tasks
        let interval = abs(self)
        let results = RadixTransform(source: Int(interval), radices: [60, 60, 24])
        let components = [
            (results[0], "d"),
            (results[1], "h"),
            (results[2], "m"),
            (results[3], "s")
        ]
        
        if let firstNonZeroIndex = components.firstIndex(where: { $0.0 != 0 }) {
            let nonZeroComponents = components[firstNonZeroIndex...]
            return nonZeroComponents.map { "\($0.0)\($0.1)" }.joined()
        }

        return "0s"
    }
}
