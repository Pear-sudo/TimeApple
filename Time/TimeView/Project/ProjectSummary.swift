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
    @Query(filter: PeriodRecordService.getRangedPredicate(start: .now, end: .now), animation: .default) private var periods: [PeriodRecord]
    @State private var offset: CGFloat = 0
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
            HPager {
                Group {
                    SummaryInstance(periods: periods)
                    SummaryInstance(periods: periods)
                    SummaryInstance(periods: periods)
                }
                .offset(x: offset)
            }
            .gesture(drag)
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged(onDragging)
            .onEnded(onDragEnded)
    }
    
    private func onDragging(value: DragGesture.Value) {
        offset = value.translation.width
        print(offset)
    }
    
    private func onDragEnded(value: DragGesture.Value) {
        offset = 0
    }
}

struct SummaryInstance: View {
    var periods: [PeriodRecord]
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                Group {
                    SummaryByProjectsView(periods: periods)
                    ProjectTimeline(periods: periods)
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

struct HPager: Layout {
    
    let requestedAnchor: Int?
    
    init(anchor: Int? = nil) {
        requestedAnchor = anchor
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        getMaxSize(proposal: proposal, subviews: subviews)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let anchor = getAnchor(viewCount: subviews.count)
        let maxSize = getMaxSize(proposal: proposal, subviews: subviews)
        subviews.enumerated().forEach { index, subview in
            let offset = CGFloat(index - anchor) * maxSize.width
            subview.place(at: .init(x: offset, y: 0), proposal: proposal)
        }
    }
    
    func getMaxSize(proposal: ProposedViewSize, subviews: Subviews) -> CGSize {
        var maxSize: CGSize = .zero
        subviews.forEach { subview in
            let size = subview.sizeThatFits(proposal)
            maxSize = .init(width: max(size.width, maxSize.width), height: max(size.height, maxSize.height))
        }
        return maxSize
    }
    
    func getAnchor(viewCount: Int) -> Int {
        let maxIndex = viewCount - 1
        if requestedAnchor == nil || requestedAnchor! > maxIndex || requestedAnchor! < 0 {
            return max(0, maxIndex / 2)
        }
        return requestedAnchor!
    }
}

#Preview {
    ProjectSummary()
}
