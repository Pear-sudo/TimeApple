//
//  OverView.swift
//  Time
//
//  Created by A on 05/08/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct StatsOverview: View {
    
    @Environment(\.viewModel) private var viewModel
    
    @Query(StatsOverview.getFetchDescriptor(predicate: PeriodRecord.predicateDailyApproximation)) private var dailyPeriods: [PeriodRecord]
    @Query(StatsOverview.getFetchDescriptor(predicate: PeriodRecord.predicateWeeklyApproximation)) private var weeklyPeriods: [PeriodRecord]
    
    let calendar = Calendar.autoupdatingCurrent
    @State private var viewID = UUID()
    @State private var isUpdating = false
    @State private var todayTotalSeconds: Double = 0
    @State private var weekTotalSeconds: Double = 0
    
    let secondsInDay = 86400.0
    let secondsInWeek = 604800.0
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("Today")
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(todayTotalSeconds.timeIntervalString)
                        .font(.title)
                    Text(" / \((todayTotalSeconds / secondsInDay).toPercentage(decimalPlaces: 2))")
                }
            }
            Spacer()
            VStack(alignment: .center) {
                Text("This week")
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(weekTotalSeconds.timeIntervalString)
                        .font(.title)
                    Text(" / \((weekTotalSeconds / secondsInWeek).toPercentage(decimalPlaces: 2))")
                }
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

extension Double {
    func toPercentage(decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f%%", self * 100)
    }
}

#Preview {
    StatsOverview()
        .modelContainer(sharedModelContainer)
        .environment(\.viewModel, viewModel)
}
