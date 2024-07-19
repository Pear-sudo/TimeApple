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
class ProjectItem {
    init(name: String, color: UInt32? = nil, parent: ProjectItem? = nil) {
        self.name = name
        self.color = color
        self.parent = parent
    }
    
    var id = UUID()
    
    var name: String
    var color: UInt32?
    var parent: ProjectItem?
    var notes: String?
}
