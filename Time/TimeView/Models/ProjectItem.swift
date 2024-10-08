//
//  ProjectItem.swift
//  Time
//
//  Created by A on 16/07/2024.
//

import Foundation
import SwiftUI
import SwiftData
import LoremSwiftum
import GeneralMacro
import MetaCodable

struct ParentAsIDCoder: HelperCoder {
    func encode(_ value: ProjectItem, to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.id)
    }

    func decode(from decoder: Decoder) throws -> ProjectItem {
        // Decoding is not needed as per your use case, so just throw an error or return a dummy value
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Decoding not supported"))
    }
}

@Model
@Codable
@Inherits(decodable: false, encodable: false)
final class ProjectItem: Identifiable, CustomStringConvertible {
    
    var description: String {
        self.name
    }
    
    init(name: String, parent: ProjectItem? = nil) {
        self.name = name
        self.parent = parent
    }
    
    var id: UUID = UUID()
    var creationTime: Date = Date()
    var accessTime: Date = Date()
    
    var name: String
    @CodedBy(ParentAsIDCoder())
    var parent: ProjectItem?
    var notes: String = ""
    var tags: [Tag] = []
    
    var r: Float = Float.random(in: 0...255) / 255
    var g: Float = Float.random(in: 0...255) / 255
    var b: Float = Float.random(in: 0...255) / 255
    
    @Attribute(.ephemeral)
    @IgnoreCoding
    var isPopoverShown: Bool = false
    
    var color: Color {
        return Color(.displayP3, red: Double(r), green: Double(g), blue: Double(b))
    }
    
    func start(context: ModelContext) {
        let period = PeriodRecord(project: self)
        context.insert(period)
        period.start()
    }
    
    static func predicate(searchText: String) -> Predicate<ProjectItem> {
        return #Predicate<ProjectItem> { item in
            searchText.isEmpty || item.name.localizedStandardContains(searchText)
        }
    }
    
    static func descriptorById(ids: Set<ProjectItem.ID>) -> FetchDescriptor<ProjectItem> {
        return .init(
            predicate: #Predicate {
                ids.contains($0.id)
            }
        )
    }
    
    static let sortByAccessTime: FetchDescriptor<ProjectItem> = FetchDescriptor<ProjectItem>(
        sortBy: [.init(\.accessTime, order: .reverse)]
    )
}

enum SortParameter: String, CaseIterable, Identifiable {
    case recentness, name
    var id: Self { self }
    var name: String {
        rawValue.capitalized
    }
}

extension Color {
    static var randomColor: Color {
        let range = 0.0...1.0
        return Color(.displayP3, red: .random(in: range), green: .random(in: range), blue: .random(in: range))
    }
}
