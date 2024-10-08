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
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
    
    let secondsInDay = 86400.0
    let secondsInWeek = 604800.0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1, paused: !periodRecordService.hasActivePeriods())) { timeContext in
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text("Today").fixedSize()
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(periodRecordService.totalSecondsDaily.timeIntervalString)
                            .font(.title)
                            .textSelection(.enabled)
                            .fixedSize()
                        Text(" / \((periodRecordService.totalSecondsDaily / secondsInDay).toPercentage(decimalPlaces: 2))")
                            .textSelection(.enabled)
                            .fixedSize()
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("This week").fixedSize()
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(periodRecordService.totalSecondsWeekly.timeIntervalString)
                            .font(.title)
                            .textSelection(.enabled)
                            .fixedSize()
                        Text(" / \((periodRecordService.totalSecondsWeekly / secondsInWeek).toPercentage(decimalPlaces: 2))")
                            .textSelection(.enabled)
                            .fixedSize()
                    }
                }
                Spacer()
            }
        }
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
