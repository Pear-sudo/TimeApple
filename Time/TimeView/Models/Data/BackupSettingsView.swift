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
            HStack {
                ShortLayout(anchor: 0) {
                    Text(urlPath)
                        .contextMenu {
                            Button("Copy path") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                let result = pasteboard.setString(urlPath, forType: .string)
                                if result == false {
                                    logger.error("Cannot set pasteboard")
                                }
                            }
                            Button("Show in Finder") {
                                let workspace = NSWorkspace.shared
                                if let url = loadThisBookmark() {
                                    let result = workspace.selectFile(url.path(), inFileViewerRootedAtPath: "")
                                    if !result {
                                        logger.error("Cannot open \(url.path()) in finder")
                                    }
                                }
                            }
                        }
                    if checkThisFolderURL() {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.green)
                            .help("Folder is accessible")
                    } else {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.red)
                            .help("Cannot access this folder")
                    }
                }
            }
            
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
        guard let bookmark = createBookmarkData(url: url) else {
            return
        }
        backupURL = bookmark
    }
    
    var urlPath: String {
        if let path = loadBookmark(bookmarkData: backupURL)?.path(), path != "" {
            return path
        }
        return "No path"
    }
    
    private func createBookmarkData(url: URL) -> Data? {
        var data: Data? = nil
        useBookmark(url) { url in
            do {
                let bookmarkData = try url.bookmarkData(
                    options: .withSecurityScope
                )
                data = bookmarkData
            } catch {
                logger.error("Cannot create bookmark from url: \(error)")
            }
        }
        return data
    }
    
    private func loadBookmark(bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: backupURL, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale, let bookmarkData = createBookmarkData(url: url) {
                backupURL = bookmarkData
            }
            return url
        } catch {
            logger.error("Cannot load bookmark url: \(error)")
            return nil
        }
    }
    
    private func loadThisBookmark() -> URL? {
        loadBookmark(bookmarkData: backupURL)
    }
    
    private func useBookmark<T>(_ url: URL, to action: (URL) -> T ) -> T? {
        if url.startAccessingSecurityScopedResource() {
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            return action(url)
        } else {
            logger.error("Call to startAccessingSecurityScopedResource() failed")
            return nil
        }
    }
    
    private func checkFolderURL(url: URL) -> Bool {
        return url.hasDirectoryPath && ((try? url.checkResourceIsReachable()) ?? false)
    }
    
    private func checkThisFolderURL() -> Bool {
        guard let bookmark = loadBookmark(bookmarkData: backupURL) else {
            return false
        }
        return useBookmark(bookmark, to: { url in
            checkFolderURL(url: url)
        }) ?? false
    }
    
    private func countBackupFiles(url: URL) -> Int {
        return 0
    }
    
    private func onFolderSelectionCancelled() {
        
    }
}
