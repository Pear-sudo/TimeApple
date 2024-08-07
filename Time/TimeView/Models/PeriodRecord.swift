//
//  Record.swift
//  Time
//
//  Created by A on 24/07/2024.
//

import Foundation
import SwiftData

@Model
class PeriodRecord {
    
    private(set) var id: UUID = UUID()
    private(set) var creationTime: Date = Date()
    
    var startTime: Date?
    var endTime: Date?
    
    var project: ProjectItem
    
    init(project: ProjectItem) {
        self.project = project
    }
    
    static let descriptorRunning = FetchDescriptor<PeriodRecord>(
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
