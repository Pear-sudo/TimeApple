//
//  Settings.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        #if os(macOS)
        SettingsInTabView()
        #elseif os(iOS)
        SettingsInNavigationStack()
        #endif
    }
    
    private enum Settings: String, CaseIterable {
        case general = "General"
        case backup = "Backup"
        
        var image: String {
            switch self {
            case .general:
                return "gear"
            case .backup:
                return "icloud"
            }
        }
    }
    
    private func SettingsInNavigationStack() -> some View {
        NavigationStack {
            List {
                ForEach(Settings.allCases, id: \.self) { item in
                    NavigationLink {
                        Text("\(item.rawValue): Work in progress...")
                            .navigationTitle(item.rawValue)
                    } label: {
                        Label(item.rawValue, systemImage: item.image)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func SettingsInTabView() -> some View {
        TabView {
            ForEach(Settings.allCases, id: \.self) { item in
                settingView(for: item)
                    .tabItem {
                        Label(item.rawValue, systemImage: item.image)
                    }
                    .tag(item)
            }
        }
        .frame(minWidth: 375, minHeight: 150)
    }
    
    @ViewBuilder
    private func settingView(for setting: Settings) -> some View {
        switch setting {
        case .general:
            GeneralSettingsView()
        case .backup:
            BackupSettingsView()
        }
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        Text("General Settings")
            .padding()
            .navigationTitle("General")
    }
}

#Preview {
    SettingsView()
}
