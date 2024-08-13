//
//  SummaryByProjectsView.swift
//  Time
//
//  Created by A on 13/08/2024.
//

import SwiftUI
import SwiftData

struct SummaryByProjectsView: View {
    @Environment(\.viewModel.periodRecordService) private var service
    
    typealias ResultMap = [ProjectItem:Int]
    
    var periods: [PeriodRecord]
    @State var sumResults: ResultMap = .init()
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1, paused: !service.hasActivePeriods())) { time in
            LazyVStack {
                ForEach(getOrderedProjectsByTotalSeconds(sumResults), id: \.0) { project, seconds in
                    ProjectViewInSummary(project: project, seconds: seconds)
                }
            }
            .onAppear {
                sumResults = sumTimeByProject(periods: periods)
            }
        }
    }
    
    private func getOrderedProjectsByTotalSeconds(_ map: ResultMap) -> [(ProjectItem, Int)] {
        let map = sumTimeByProject(periods: periods) // TODO: cache the results, increase efficiency
        return map.sorted(by: {$0.value > $1.value})
    }
    
    private func sumTimeByProject(periods: [PeriodRecord]) -> ResultMap {
        var resultMap = [ProjectItem:Int]()
        for period in periods {
            guard let seconds = period.seconds else {
                continue
            }
            let project = period.project
            let accumulation = resultMap[project] ?? 0
            resultMap[project] = accumulation + seconds
        }
        return resultMap
    }
}

#Preview {
    @Previewable @Query(filter: PeriodRecordService.getRangedPredicate(start: .now, end: .now), animation: .default)  var periods: [PeriodRecord]
    SummaryByProjectsView(periods: periods)
}
