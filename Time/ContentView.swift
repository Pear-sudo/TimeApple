//
//  ContentView.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projectItems: [ProjectItem]

    var body: some View {
        Text("")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ProjectItem.self, inMemory: true)
}
