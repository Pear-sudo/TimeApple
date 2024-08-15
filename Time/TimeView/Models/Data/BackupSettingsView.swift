//
//  BackupSettingsView.swift
//  Time
//
//  Created by A on 15/08/2024.
//

import SwiftUI

struct BackupSettingsView: View {
    @State private var fileExporterIsPresented = false
    private let exporter = JsonExporter()
    var body: some View {
        VStack {
            Button("Export") {
                if exporter.export() {
                    fileExporterIsPresented = true
                }
            }
        }
        .fileExporter(isPresented: $fileExporterIsPresented, item: exporter, onCompletion: { result in
            if case .success(let url) = result {
                print(url)
            }
        })
        .navigationTitle("Backup")
    }
}
