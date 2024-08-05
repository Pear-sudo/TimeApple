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
    
    @Environment(ViewModel.self) private var viewModel
    
    @Query(Overview.getFetchDescriptor(predicate: PeriodRecord.predicateDailyApproximation)) private var dailyPeriods: [PeriodRecord]
    @Query(Overview.getFetchDescriptor(predicate: PeriodRecord.predicateWeeklyApproximation)) private var weeklyPeriods: [PeriodRecord]
    
    let calendar = Calendar.autoupdatingCurrent
    @State private var viewID = UUID()
    @State private var isUpdating = false
    @State private var todayTotalSeconds: Double = 0
    @State private var weekTotalSeconds: Double = 0
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("Today")
                Text(todayTotalSeconds.timeIntervalString)
                    .font(.title)
            }
            Spacer()
            VStack(alignment: .center) {
                Text("This week")
                Text(weekTotalSeconds.timeIntervalString)
                    .font(.title)
            }
            Spacer()
        }
        .onAppear {
            updateSeconds()
            checkUpdate()
        }
        .onDisappear {
            endUpdate()
        }
        .onChange(of: viewModel.runningProjectCount) {
            checkUpdate()
        }
        .onChange(of: dailyPeriods) {
            updateSeconds()
        }
    }
    
    private func checkUpdate() {
        if viewModel.runningProjectCount == 0 {
            endUpdate()
        } else {
            if !isUpdating {
                startUpdate()
            }
        }
    }
    
    private func startUpdate() {
        isUpdating = true
        viewModel.subscribe(id: viewID) {
            updateSeconds()
        }
    }
    
    private func endUpdate() {
        isUpdating = false
        viewModel.unsubscribe(id: viewID)
    }
    
    private func updateSeconds() {
        todayTotalSeconds = getTodayTotalSeconds()
        weekTotalSeconds = getWeekTotalSeconds()
    }
    
    private func getTodayTotalSeconds() -> Double {
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
    
    private func getWeekTotalSeconds() -> Double {
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
        .environment(ViewModel())
}
