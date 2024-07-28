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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProjectItem.self,
            PeriodRecord.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ItemListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
