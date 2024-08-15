//
//  BackupSettingsView.swift
//  Time
//
//  Created by A on 15/08/2024.
//

import SwiftUI
import OSLog
import GeneralMacro

struct BackupSettingsView: View {
    private let logger = #logger(\Subsystem.data, \DataSubsystemCategory.backup)
    @State private var fileExporterIsPresented = false
    @State private var fileImporterIsPresented = false
    @AppStorage("backupFolder") private var backupURL: Data = .init()
    private let exporter = JsonExporter()
    var body: some View {
        VStack {
            Button("Export") {
                if exporter.export() {
                    fileExporterIsPresented = true
                }
            }
            Button("Folder") {
                fileImporterIsPresented = true
            }
            Text(String(data: backupURL, encoding: .utf8) ?? "No path")
        }
        .fileExporter(isPresented: $fileExporterIsPresented, item: exporter, onCompletion: { result in
            if case .success(let url) = result {
                print(url)
            }
        })
        .fileImporter(isPresented: $fileImporterIsPresented, allowedContentTypes: [.folder], allowsMultipleSelection: false, onCompletion: onFolderSelected, onCancellation: onFolderSelectionCancelled)
        .navigationTitle("Backup")
    }
    
    private func onFolderSelected(result: Result<[URL], any Error>) {
        guard case .success(let urls) = result else {
            return
        }
        guard let url = urls.first else {
            return
        }
        if let urlData = url.absoluteString.data(using: .utf8) {
            backupURL = urlData
        }
    }
    
    private func createBookmarkData(url: URL) -> Data? {
        return try? url.bookmarkData(
            options: .withSecurityScope
        )
    }
    
    private func onFolderSelectionCancelled() {
        
    }
}
