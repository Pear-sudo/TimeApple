//
//  ProjectItem.swift
//  Time
//
//  Created by A on 16/07/2024.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class ProjectItem: Identifiable {
    init(name: String, parent: ProjectItem? = nil) {
        self.name = name
        self.parent = parent
    }
    
    var id = UUID()
    var creationTime = Date()
    var accessTime = Date()
    
    var name: String
    var parent: ProjectItem?
    var notes: String?
    
    var r: Float = Float.random(in: 0...255) / 255
    var g: Float = Float.random(in: 0...255) / 255
    var b: Float = Float.random(in: 0...255) / 255
    
    @Attribute(.ephemeral)
    var isPopoverShown = false
    
    var color: Color {
        return Color(.displayP3, red: Double(r), green: Double(g), blue: Double(b))
    }
    
    static func descriptorById(ids: Set<ProjectItem.ID>) -> FetchDescriptor<ProjectItem> {
        return .init(
            predicate: #Predicate {
                ids.contains($0.id)
            }
        )
    }
    
    static let sortByAccessTime = FetchDescriptor<ProjectItem>(
        sortBy: [.init(\.accessTime, order: .reverse)]
    )
}
