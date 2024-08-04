//
//  TimeApp.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI
import SwiftData

let models: [any PersistentModel.Type] = [ProjectItem.self, PeriodRecord.self, Tag.self]

@main
struct TimeApp: App {
    @State private var viewModel = ViewModel()
        
    var body: some Scene {
#if os(iOS)
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(for: models, isUndoEnabled: false)
#elseif os(macOS)
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(for: models, isUndoEnabled: false)
        
        Settings {
            SettingsView()
        }
#endif
    }
}
