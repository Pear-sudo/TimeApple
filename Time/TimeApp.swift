//
//  TimeApp.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI
import SwiftData

let models: [any PersistentModel.Type] = [ProjectItem.self, PeriodRecord.self, Tag.self]
var viewModel = ViewModel(context: ModelContext(sharedModelContainer))

/// a same model container must be shared between multiple window groups if you want the data to be synced
var sharedModelContainer: ModelContainer = {
    let schema = Schema(models)
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

@main
struct TimeApp: App {
    @State private var viewModel = ViewModel(context: ModelContext(sharedModelContainer))
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.viewModel, viewModel)
        }
        .modelContainer(sharedModelContainer)
        .commands() {
            CommandGroup(before: .newItem) {
                Button("New Project") {
                    openWindow(id: WindowId.projectEditor.rawValue)
                }
                .keyboardShortcut("p")
                Divider()
            }
        }
        
        WindowGroup(id: WindowId.projectEditor.rawValue, for: PersistentIdentifier.self) { id in
            ProjectCreation(id: id.wrappedValue)
        }
        .modelContainer(sharedModelContainer)
        
#if os(macOS)
        Settings {
            SettingsView()
        }
        .modelContainer(sharedModelContainer)
#endif
    }
}

enum WindowId: String {
    case projectEditor
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}

private struct ViewModelEnvironmentKey: EnvironmentKey {
    static let defaultValue: ViewModel = ViewModel(context: ModelContext(sharedModelContainer))
}

extension EnvironmentValues {
    var viewModel: ViewModel {
        get {
            self[ViewModelEnvironmentKey.self]
        }
        set {
            self[ViewModelEnvironmentKey.self] = newValue
        }
    }
}
