//
//  ContentView.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            Text("No groups yet")
                .toolbar {
                    Button("New Group", systemImage: "folder.badge.plus") {
                        
                    }
                }
        } detail: {
            Dashboard()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self])
        .environment(\.viewModel, viewModel)
}
