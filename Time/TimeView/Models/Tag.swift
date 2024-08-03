//
//  Tag.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import Foundation
import SwiftData

@Model
class Tag {
    
    @Attribute(.unique)
    private var name: String
    
    let creationTime: Date = Date()
    private(set) var modificationTime: Date = Date()
    
    init(name: String) {
        self.name = name
    }
    
    func rename(_ newName: String) {
        self.name = newName
        self.modificationTime = Date()
    }
}
