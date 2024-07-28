//
//  Record.swift
//  Time
//
//  Created by A on 24/07/2024.
//

import Foundation
import SwiftData

@Model
class PeriodRecord {
    
    private(set) var id: UUID = UUID()
    private(set) var creationTime: Date = Date()
    
    var beginTime: Date?
    var endTime: Date?
    
    var project: ProjectItem
    
    init(project: ProjectItem) {
        self.project = project
    }
    
    static let descriptorRunning = FetchDescriptor<PeriodRecord>(
        predicate: #Predicate { record in
            record.beginTime != nil && record.endTime == nil
        },
        sortBy: [
            .init(\.beginTime, order: .forward)
        ]
    )
    
    static let descriptorLastStopped: FetchDescriptor<PeriodRecord> = {
        var descriptor = FetchDescriptor<PeriodRecord> (
            predicate: #Predicate { record in
                record.beginTime != nil && record.endTime != nil
            },
            sortBy: [
                .init(\.endTime, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }()
    
    func start() {
        self.beginTime = Date()
    }
    
    func end() {
        self.endTime = Date()
    }
    
    var isPending: Bool {
        self.beginTime == nil && self.endTime == nil
    }
    
    var isRunning: Bool {
        self.beginTime != nil && self.endTime == nil
    }
    
    var isStopped: Bool {
        self.beginTime != nil && self.endTime != nil
    }
    
    var status: Status {
        if isPending {
            return .pending
        }
        if isRunning {
            return .running
        }
        return .stopped
    }
    
    enum Status {
        case pending, running, stopped
    }
}
