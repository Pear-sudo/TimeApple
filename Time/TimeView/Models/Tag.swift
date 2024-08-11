//
//  Tag.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import Foundation
import SwiftData
import LoremSwiftum

struct TagSkeleton {
    var name: String = Lorem.word
    
    var creationTime: Date = Date()
    var modificationTime: Date = Date()
}

@Model
class Tag {
    
    @Attribute(.unique)
    private(set) var name: String
    
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
