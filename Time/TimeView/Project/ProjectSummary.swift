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
    @State private var previousOffset: CGFloat = 0
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
            GeometryReader { geometry in
                HPager {
                    Group {
                        SummaryInstance(periods: periods)
                        SummaryInstance(periods: periods)
                        SummaryInstance(periods: periods)
                    }
                    .offset(x: offset)
                }
                .gesture(drag(geometry: geometry))
            }
        }
    }
    
    private func drag(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged(onDragging(geometry: geometry))
            .onEnded(onDragEnded(geometry: geometry))
    }
    
    private func onDragging(geometry: GeometryProxy) -> (DragGesture.Value) -> Void {
        { value in
            offset = previousOffset + value.translation.width
        }
    }
    
    private func onDragEnded(geometry: GeometryProxy) -> (DragGesture.Value) -> Void {
        { value in
            if abs(value.predictedEndTranslation.width) > geometry.size.width / 2 && !dragIsAtEdge(geometry: geometry) {
                animateDrag {
                    offset = previousOffset + geometry.size.width * (value.predictedEndTranslation.width > 0 ? 1 : -1)
                }
                previousOffset = offset
            } else {
                animateDrag {
                    offset = previousOffset
                }
            }
        }
    }
    
    private func dragIsAtEdge(geometry: GeometryProxy) -> Bool {
        let anchor = 1
        let total = 3
        let leftEdge = CGFloat(0 - anchor) * geometry.size.width
        let rightEdge = CGFloat(total - 1 - anchor) * geometry.size.width
        if offset < leftEdge || offset > rightEdge {
            return true
        } else {
            return false
        }
    }
    
    private func animateDrag<Result>(_ body: () -> Result, callCompletionHandler: Bool = true) {
        let _ = withAnimation(.easeOut) {
            body()
        } completion: {
            if callCompletionHandler {
                handleDragAnimationComplete()
            }
        }
    }
    
    private func handleDragAnimationComplete() {
        // TODO: check and replace underlying views
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
