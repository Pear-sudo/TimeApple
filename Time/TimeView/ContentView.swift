//
//  ContentView.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var preferredCompactColumn = NavigationSplitViewColumn.content
    
    @State private var hideDetailColumn = false
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ){
            Text("No groups yet")
                .toolbar {
                    Button("New Group", systemImage: "folder.badge.plus") {
                        
                    }
                }
        } content: {
            ProjectSummary()
                .navigationSplitViewColumnWidth(ideal: 0, max: detailMax) // this only works for macOS
        } detail: {
            Dashboard()
                .navigationSplitViewColumnWidth(ideal: 500)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Hide detail", systemImage: "sidebar.trailing") {
                    hideDetailColumn.toggle()
                }
                .help("Hide detail")
            }
        }
    }
    
    private var detailMax: CGFloat? {
        hideDetailColumn ? 0 : nil
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self])
        .environment(\.viewModel, viewModel)
        .frame(width: 800)
}
