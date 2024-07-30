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
    var body: some Scene {
        WindowGroup {
            ItemListView()
        }
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self], isUndoEnabled: false)
    }
}
