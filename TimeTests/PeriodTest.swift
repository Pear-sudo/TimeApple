//
//  PeriodTest.swift
//  TimeTests
//
//  Created by A on 14/08/2024.
//

import Foundation
import Testing
@testable import Time

struct PeriodTest {
    
    let calendar = Calendar.current

    @Test func noTimeAtAll() async throws {
        let period = newPeriod
        #expect(period.dailySegments() == [])
    }
    
    @Test func inverseTime() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 23).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 22).date!
        #expect(period.dailySegments() == [])
    }
    
    @Test func equalTime() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 23).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 23).date!
        #expect(period.dailySegments() == [])
    }
    
    @Test func oneSecond() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 23).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 9, minute: 23, second: 24).date!
        #expect(period.dailySegments() == [.init(start: period.startTime!, end: period.endTime!)])
    }
    
    @Test func oneSecondBeforeNewDay() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 9, hour: 23, minute: 59, second: 59).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 0, minute: 0, second: 0).date!
        #expect(period.dailySegments() == [.init(start: period.startTime!, end: period.endTime!)])
    }
    
    @Test func oneSecondAfterNewDay() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 0, minute: 0, second: 0).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 0, minute: 0, second: 1).date!
        #expect(period.dailySegments() == [.init(start: period.startTime!, end: period.endTime!)])
    }
    
    @Test func noEndTime() async throws {
        let period = newPeriod
        period.startTime = .now
        try await Task.sleep(for: .seconds(1))
        #expect(period.dailySegments().count == 1)
    }
    
    @Test func one() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 15, minute: 0, second: 0).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 17, minute: 4, second: 1).date!
        #expect(period.dailySegments() == [.init(start: period.startTime!, end: period.endTime!)])
    }
    
    @Test func two() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 15, minute: 0, second: 0).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 11, hour: 17, minute: 4, second: 1).date!
        #expect(period.dailySegments() == [
            .init(start: period.startTime!, end: DateComponents(calendar: calendar, year: 1989, month: 9, day: 11, hour: 0, minute: 0, second: 0).date!),
            .init(start: DateComponents(calendar: calendar, year: 1989, month: 9, day: 11, hour: 0, minute: 0, second: 0).date!, end: period.endTime!),
        ]
        )
    }
    
    @Test func three() async throws {
        let period = newPeriod
        period.startTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 10, hour: 15, minute: 0, second: 0).date!
        period.endTime = DateComponents(calendar: calendar, year: 1989, month: 9, day: 12, hour: 0, minute: 0, second: 1).date!
        #expect(period.dailySegments() == [
            .init(start: period.startTime!, end: DateComponents(calendar: calendar, year: 1989, month: 9, day: 11, hour: 0, minute: 0, second: 0).date!),
            .init(start: DateComponents(calendar: calendar, year: 1989, month: 9, day: 11, hour: 0, minute: 0, second: 0).date!, end: DateComponents(calendar: calendar, year: 1989, month: 9, day: 12, hour: 0, minute: 0, second: 0).date!),
            .init(start: DateComponents(calendar: calendar, year: 1989, month: 9, day: 12, hour: 0, minute: 0, second: 0).date!, end: DateComponents(calendar: calendar, year: 1989, month: 9, day: 12, hour: 0, minute: 0, second: 1).date!)
        ]
        )
    }
    
    
    var newPeriod: PeriodRecord {
        PeriodRecord(project: ProjectItem(name: ""))
    }

}
