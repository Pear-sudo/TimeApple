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
            Text("default list")
                .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 200)
        } detail: {
            DetailView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self])
        .environment(ViewModel())
}
