//
//  ProjectViewInSummary.swift
//  Time
//
//  Created by A on 13/08/2024.
//

import SwiftUI

struct ProjectViewInSummary: View {
    var project: ProjectItem
    var seconds: Int?
    var body: some View {
        HStack {
            ShortLayout {
                Capsule().fill(project.color).frame(width: 4)
                Text(project.name)
                    .padding(.vertical, 4)
                    .font(.title3)
            }
            Spacer()
            if let seconds = seconds {
                DurationView(duration: .seconds(seconds))
            } else {
                Text("Error: cannot compute total seconds")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    ProjectViewInSummary(
        project: ProjectItem(name: "Sample"),
        seconds: 650
    )
    .padding()
}
