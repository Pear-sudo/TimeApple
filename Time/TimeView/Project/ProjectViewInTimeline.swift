//
//  ProjectViewInTimeline.swift
//  Time
//
//  Created by A on 09/08/2024.
//

import SwiftUI

struct ProjectViewInTimeline: View {
    var body: some View {
        ShortLayout {
            Timeline(circleSize: 10)
            HStack(alignment: .top) {
                ProjectInfo()
                Spacer()
                DurationView()
            }
            .padding(.vertical, 10)
        }
    }
}

struct TimePoint: View {
    let date: Date = .now
    var body: some View {
        Text(date, style: .time)
            .font(.body)
            .foregroundStyle(.gray)
    }
}

#Preview("TimePoint") {
    TimePoint()
}

struct Timeline: View {
    var color: Color = Color.randomColor
    var circleSize: Double = 10
    var body: some View {
        VStack(spacing: -circleSize/2) {
            TimelineCircle
            color
                .frame(width: lineWidth)
            TimelineCircle
        }
        .frame(minWidth: lineWidth)
    }
    var lineWidth: Double {
        circleSize / 2
    }
    var TimelineCircle: some View {
        Circle()
            .fill(color)
            .frame(width: circleSize)
    }
}

struct ProjectInfo: View {
    var firstLine: String = "Time"
    var secondLine: String = "Programming projects"
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                Text(LocalizedStringKey(firstLine))
                    .font(.title)
                Text(LocalizedStringKey(secondLine))
                    .foregroundStyle(.gray)
            }
            .lineLimit(1, reservesSpace: true)
        }
    }
}

struct DurationView: View {
    var duration: Duration = .seconds(9874560) + .milliseconds(12)
    var format: Duration.UnitsFormatStyle = .units(
        allowed: [.weeks, .days, .hours, .minutes, .seconds],
        width: .narrow,
        maximumUnitCount: nil,
        zeroValueUnits: .hide,
        valueLength: nil,
        fractionalPart: .hide
    )
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(duration.formatted(format))
                .textCase(.uppercase)
                .font(.body.monospaced())
        }
    }
}

struct ShortLayout: Layout {
    
    var anchor: Int = -1
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let spacing = spacing(subviews: subviews)

        let maxHeight = getMaxHeight(subviews: subviews, anchor: anchor)
        let totalWidth = widths(proposal: proposal, subviews: subviews, spacing: spacing, maxHeight: maxHeight).1 // spacing is included
        
        return CGSize(
            width: totalWidth,
            height: maxHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let maxHeight = getMaxHeight(subviews: subviews, anchor: anchor)
        let spacing = spacing(subviews: subviews)
        let widths = widths(proposal: proposal, subviews: subviews, spacing: spacing, maxHeight: maxHeight).0

        var nextX: CGFloat = bounds.minX

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: nextX, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: widths[index], height: maxHeight))
            nextX += widths[index] + spacing[index]
        }
    }
    
    private func getMaxHeight(subviews: Subviews, anchor: Int) -> Double {
        var anchor = anchor
        if anchor < 0 {
            anchor = subviews.count + anchor
        }
        if anchor < subviews.startIndex || anchor > subviews.endIndex {
            anchor = subviews.endIndex
        }
        
        return subviews[anchor].sizeThatFits(.unspecified).height
    }
    
    /// Gets an array of preferred spacing sizes between subviews in the
    /// horizontal dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
    
    private func widths(proposal: ProposedViewSize, subviews: Subviews, spacing: [CGFloat], maxHeight: CGFloat) -> ([CGFloat], CGFloat) {
        var totalWidth: CGFloat = 0
        return (subviews.indices.map { index in
            let width = subviews[index].sizeThatFits(.init(width: minus(proposal.width, totalWidth), height: maxHeight)).width
            totalWidth = totalWidth + width + spacing[index]
            return width
        }, totalWidth)
    }
    
    @inline(__always)
    private func minus(_ x: CGFloat?, _ y: CGFloat?) -> CGFloat? {
        if x == nil || y == nil {
            return nil
        }
        return x! - y!
    }
}

#Preview {
    ProjectViewInTimeline()
        .frame(width: 400, height: 200)
}

#Preview("Timeline") {
    Timeline()
        .frame(width: 100, height: 100)
}

#Preview("ProjectInfo") {
    ProjectInfo()
        .frame(width: 200, height: 100)
}

#Preview("Duration") {
    DurationView()
        .frame(width: 200, height: 100)
}
