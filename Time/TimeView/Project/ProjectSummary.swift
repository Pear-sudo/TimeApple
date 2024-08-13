//
//  ProjectSummary.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI
import SwiftData

struct ProjectSummary: View {
    @Environment(\.viewModel) private var viewModel
    var interval: DateInterval
    init() {
        self.init(
            interval: .init(start: Calendar.autoupdatingCurrent.startOfDay(for: .now), end: .now)
        )
    }
    init(interval: DateInterval) {
        self.interval = interval
    }
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack(path: $viewModel.presentedPeriods) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    Group {
                        ProjectTimeline()
                    }
                    .padding()
                    .background(Color.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(8)
            }
            .defaultScrollAnchor(.top)
            .navigationDestination(for: PeriodRecord.self) { period in
                PeriodEditingView(period: period)
            }
        }
    }
}

#Preview {
    ProjectSummary()
}
