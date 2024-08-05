//
//  OverView.swift
//  Time
//
//  Created by A on 05/08/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct Overview: View {
    
    @Query(Overview.getFetchDescriptor(predicate: PeriodRecord.predicateDailyApproximation)) private var dailyPeriods: [PeriodRecord]
    @Query(Overview.getFetchDescriptor(predicate: PeriodRecord.predicateWeeklyApproximation)) private var weeklyPeriods: [PeriodRecord]
    
    let calendar = Calendar.autoupdatingCurrent
    
    var body: some View {
        HStack {
            VStack {
                Text("Today")
                Text(todayTotalSeconds.timeIntervalString)
            }
            VStack {
                Text("This week")
                Text(weekTotalSeconds.timeIntervalString)
            }
        }
    }
    
    private var todayTotalSeconds: Double {
        return dailyPeriods.reduce(0) { result, period in
            
            var end = period.endTime ?? Date.now
            if !calendar.isDateInToday(end) {
                guard let e = calendar.endOfDay(for: end) else {
                    return result
                }
                end = e.addingTimeInterval(-1)
            }
            
            let interval = end.timeIntervalSince(period.startTime!)
            if interval <= 0 {
                return result
            }
            
            return result + interval
        }
    }
    
    private var weekTotalSeconds: Double {
        return weeklyPeriods.reduce(0) { result, period in
            var end = period.endTime ?? Date.now
            let weekEnd = calendar.dateInterval(of: .weekOfYear, for: .now)!.end
            if end >= weekEnd {
                end = weekEnd.addingTimeInterval(-1)
            }
            
            let interval = end.timeIntervalSince(period.startTime!)
            if interval <= 0 {
                return result
            }
            
            return result + interval
        }
    }
    
    static func getFetchDescriptor(predicate: Predicate<PeriodRecord>) -> FetchDescriptor<PeriodRecord> {
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.propertiesToFetch = [\.startTime, \.endTime]
        return descriptor
    }
    
}

#Preview {
    Overview()
        .modelContainer(sharedModelContainer)
}
