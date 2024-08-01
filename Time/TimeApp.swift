//
//  TimeApp.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI
import SwiftData

@main
struct TimeApp: App {
    @State private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self], isUndoEnabled: false)
    }
}
