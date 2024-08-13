//
//  ProjectTimeline.swift
//  Time
//
//  Created by A on 09/08/2024.
//

import SwiftUI
import SwiftData
import OSLog

let domainName = "cyou.b612.time"

struct ProjectTimeline: View {
    private let logger = Logger(subsystem: "\(domainName).view", category: "ProjectTimeline")
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
    @Environment(\.viewModel) private var viewModel
    @Query(filter: PeriodRecordService.getRangedPredicate(start: .now, end: .now), animation: .default) private var periods: [PeriodRecord]
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Text("Timeline")
                .font(.largeTitle)
            ForEach(Array(periods.enumerated()), id: \.element.hashValue) { index, period in
                ProjectViewInTimeline(period: period)
                    .padding(.leading, 8)
                    .contentShape(.rect)
                    .onTapGesture {
                        viewModel.presentedPeriods.append(period)
                    }
                if index != periods.count - 1 && period.isStopped {
                    if periods[index + 1].startTime!.timeIntervalSince(periods[index].endTime!) >= 0 {
                        BreakLine(duration: .seconds(periods[index + 1].startTime!.timeIntervalSince(periods[index].endTime!)))
                    }
                } else if period.isStopped {
                    BreakLine(start: period.endTime!)
                }
            }
        }
    }
}

struct BreakLine: View {
    var duration: Duration = .seconds(8930) + .milliseconds(12)
    var start: Date? = nil
    init() {}
    init(duration: Duration) {
        self.duration = duration
    }
    init(start: Date) {
        self.start = start
    }
    var body: some View {
        ShortLayout {
            Image(systemName: "cup.and.saucer.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack {
                Text("Break")
                    .foregroundStyle(.secondary)
                Spacer()
                if let start = start {
                    DurationView(start: start)
                } else {
                    DurationView(duration: duration)
                }
            }
            .padding(.vertical, 3)
            .padding(.leading, 3)
        }
    }
}

#Preview("BreakLine") {
    BreakLine()
}
