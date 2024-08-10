//
//  ProjectTimeline.swift
//  Time
//
//  Created by A on 09/08/2024.
//

import SwiftUI

struct ProjectTimeline: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Text("Timeline")
                .font(.largeTitle)
            TimePoint()
            ProjectViewInTimeline()
                .padding(.leading, 8)
            TimePoint()
            BreakLine()
        }
    }
}

struct BreakLine: View {
    var duration: Duration = .seconds(8930) + .milliseconds(12)
    var body: some View {
        ShortLayout {
            Image(systemName: "cup.and.saucer.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack {
                Text("Break")
                    .foregroundStyle(.gray)
                Spacer()
                DurationView(duration: duration)
            }
            .padding(.vertical, 3)
            .padding(.leading, 3)
        }
    }
}

#Preview("BreakLine") {
    BreakLine()
}


#Preview("ProjectTimeline") {
    ProjectTimeline()
}
