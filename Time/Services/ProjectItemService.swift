//
//  ProjectItemService.swift
//  Time
//
//  Created by A on 07/08/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ProjectItemService {
    @ObservationIgnored
    private var context: ModelContext
        
    init(context: ModelContext) {
        self.context = context
    }
    
    func getAll() -> [ProjectItem] {
        
        return []
    }
}
