//
//  History.swift
//  Time
//
//  Created by A on 07/08/2024.
//

import SwiftUI
import Charts

struct History: View {
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
    let calendar = Calendar.autoupdatingCurrent
    var body: some View {
        Chart(periods) { period in
            BarMark(
                x: .value("Date", calendar.component(.day, from: period.startTime!)),
                yStart: .value("Start", period.startTime!.hoursDaily),
                yEnd: .value("End", period.endTime!.hoursDaily),
                width: 60
            )
            .foregroundStyle(by: .value("Project", period.project.name))
        }
        .chartYScale(domain: [24, 0])
        .chartYAxis {
            AxisMarks(
                preset: .aligned,
                position: .leading,
                values: Array(1...23)
            ) {
                AxisValueLabel(
                    format: IntegerFormatStyle<Int>().grouping(.never).precision(.integerLength(2))
                )
                .font(.footnote.monospaced())
            }
            AxisMarks(
                position: .leading,
                values: Array(1...23)
            ) {
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(
                
            ) {
                AxisValueLabel(
                    format: .dateTime.day(.twoDigits).weekday(.abbreviated)
                )
                AxisGridLine()
            }
        }
    }
    var periods: [PeriodRecord] {
        let periods = periodRecordService.getDailyClippedPeriods(from: calendar.date(byAdding: .day, value: -1, to: .now)!, to: .now)
        return periods
    }
}

extension Date {
    var timeIntervalDaily: TimeInterval {
        self.timeIntervalSince(Calendar.autoupdatingCurrent.startOfDay(for: self))
    }
    var hoursDaily: Double {
        self.timeIntervalDaily / 3600.0
    }
}

#Preview {
    History()
        .modelContainer(sharedModelContainer)
        .environment(\.viewModel, viewModel)
}
