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
    
    var startTime: Date?
    var endTime: Date?
    
    var project: ProjectItem
    
    init(project: ProjectItem) {
        self.project = project
    }
    
    static let descriptorRunning = FetchDescriptor<PeriodRecord>(
        predicate: #Predicate { record in
            record.startTime != nil && record.endTime == nil
        },
        sortBy: [
            .init(\.startTime, order: .forward)
        ]
    )
    
    static let descriptorLastStopped: FetchDescriptor<PeriodRecord> = {
        var descriptor = FetchDescriptor<PeriodRecord> (
            predicate: #Predicate { record in
                record.startTime != nil && record.endTime != nil
            },
            sortBy: [
                .init(\.endTime, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }()
    
    func start() {
        let now = Date()
        self.startTime = now
        self.project.accessTime = now
    }
    
    func end() {
        self.endTime = Date()
    }
    
    var isPending: Bool {
        self.startTime == nil && self.endTime == nil
    }
    
    var isRunning: Bool {
        self.startTime != nil && self.endTime == nil
    }
    
    var isStopped: Bool {
        self.startTime != nil && self.endTime != nil
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
