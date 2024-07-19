//
//  ProjectEntryView.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI

struct ProjectItemView: View {
    @State var projectItem: ProjectItem
    var body: some View {
        HStack {
            VStack {
                Text(projectItem.name)
                Text(projectItem.parent?.name ?? "")
                Text(timeString)
            }
            Image(systemName: "chevron.down")
                .onTapGesture(perform: expand)
            Button("more", systemImage: "ellipsis", action: more)
                .labelStyle(.iconOnly)
        }
    }
    private func expand() {
        
    }
    private func more() {
        
    }
    var timeString: String {
        ""
    }
}

let sport = ProjectItem(name: "Sport")

#Preview {
    ProjectItemView(projectItem: sport)
        .padding()
        .modelContainer(for: ProjectItem.self, inMemory: true)
}
