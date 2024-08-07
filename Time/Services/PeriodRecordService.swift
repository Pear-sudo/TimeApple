//
//  PeriodRecordService.swift
//  Time
//
//  Created by A on 07/08/2024.
//

import Foundation
import SwiftData

@Observable
class PeriodRecordService {

    private var context: ModelContext
    private(set) var activePeriods: [UUID:PeriodRecord] = [:]
    
    init(context: ModelContext) {
        self.context = context
        if let unfinishedPeriods = try? context.fetch(FetchDescriptor<PeriodRecord>(
            predicate: #Predicate<PeriodRecord> { period in
                !(period.startTime != nil && period.endTime != nil)
            })) {
            var activePeriods: [UUID:PeriodRecord] = [:]
            unfinishedPeriods.forEach { period in
                if period.startTime !=  nil {
                    if activePeriods[period.project.id] != nil {
                        print("abnormal period detected, removing...")
                        context.delete(period)
                    } else {
                        activePeriods[period.project.id] = period
                    }
                } else {
                    print("abnormal period detected, removing...")
                    context.delete(period)
                }
            }
            self.activePeriods = activePeriods
        }
    }
    
    subscript(key: ProjectItem) -> PeriodRecord? {
        return activePeriods[key.id]
    }
    
    func start(project: ProjectItem) {
        if activePeriods[project.id] != nil {
            return
        }
        let period = PeriodRecord(project: project)
        context.insert(period)
        period.start()
        
        activePeriods[project.id] = period
    }
    
    func stop(project: ProjectItem) {
        if let period = activePeriods[project.id] {
            period.stop()
            activePeriods[project.id] = nil
        }
    }
    
    func hasActivePeriods() -> Bool {
        return !activePeriods.isEmpty
    }
    
    func hasActivePeriods(for project: ProjectItem) -> Bool {
        return activePeriods[project.id] != nil
    }
}
