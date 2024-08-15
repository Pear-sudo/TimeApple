//
//  JsonExporter.swift
//  Time
//
//  Created by A on 15/08/2024.
//

import Foundation
import SwiftData
import CoreTransferable

class JsonExporter: Transferable {
    
    enum ExporterError: Error {
        case noData
    }
    
    let context: ModelContext = .init(sharedModelContainer)
    let encoder = JSONEncoder()
    var data: Data? = nil
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { exporter in
            if exporter.data != nil {
                return exporter.data!
            } else {
                throw ExporterError.noData
            }
        }
    }
    
    func export() -> Bool {
        guard let tags = try? context.fetch(FetchDescriptor<Tag>()) else {
            return false
        }
        guard let periods = try? context.fetch(FetchDescriptor<PeriodRecord>()) else {
            return false
        }
        guard let projects = try? context.fetch(FetchDescriptor<ProjectItem>()) else {
            return false
        }
        let database = Database(tags: tags, periods: periods, projects: projects)
        guard let jsonData = try? encoder.encode(database) else {
            return false
        }
        data = jsonData
        return true
    }
    
    struct Database: Codable {
        var tags: [Tag]
        var periods: [PeriodRecord]
        var projects: [ProjectItem]
    }
}
