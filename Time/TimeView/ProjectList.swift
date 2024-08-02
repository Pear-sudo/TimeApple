//
//  ProjectList.swift
//  Time
//
//  Created by A on 01/08/2024.
//

import SwiftUI
import SwiftData

struct ProjectList: View {
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\ProjectItem.accessTime, order: .reverse)], animation: .default) var items: [ProjectItem]
    @Query(PeriodRecord.descriptorRunning, animation: .default) var runningItems: [PeriodRecord]
    @Query(PeriodRecord.descriptorLastStopped, animation: .default) var lastStopped: [PeriodRecord]

    
    @Binding var selectedIds: Set<ProjectItem.ID>
    
    private let horizontalSpacing: CGFloat = 8
    
    init(
        selectedIds: Binding<Set<ProjectItem.ID>>,
        
        sortParameter: SortParameter = .recentness,
        sortOrder: SortOrder = .reverse
    ) {
        self._selectedIds = selectedIds
        switch sortParameter {
        case .recentness:
            _items = Query(sort: \.accessTime, order: sortOrder)
        case .name:
            _items = Query(sort: \.name, order: sortOrder)
        }
    }

    var body: some View {
        List(selection: $selectedIds) {
            if !headerPeriods.isEmpty {
                ZStack {
                    ActiveProjectView(period: headerPeriods.first!)
                        .disabled(true)
                        .hidden()
                    GeometryReader { geometry in
                        ScrollView([.horizontal]) {
                            HStack(spacing: horizontalSpacing) {
                                ForEach(headerPeriods) { period in
                                    ActiveProjectView(period: period)
                                        .frame(minWidth: calculateActiveProjectViewWidth(geometry.size.width))
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
            }
            Section {
                ForEach(items) {item in
                    ProjectItemView(item: item)
                        .listRowSeparator(.hidden)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .shadow(radius: 3)
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
        }
        .padding(10)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(backgroundColor)
    }
    
    private func calculateActiveProjectViewWidth(_ width: CGFloat) -> CGFloat {
        
        let minWidth: CGFloat = 100
        let numberOfPeriods = CGFloat(headerPeriods.count)
        let availableWidth = width - (numberOfPeriods - 1) * horizontalSpacing
        let calculatedWidth = availableWidth / numberOfPeriods
        
        return max(minWidth, calculatedWidth)
    }
    

    
    var headerPeriods: [PeriodRecord] {
        if runningItems.isEmpty {
            return lastStopped
        }
        return runningItems
    }
    
    var backgroundColor: Color {
        var color = headerPeriods.first?.project.color ?? Color.accentColor
        color = color.opacity(0.2)
        return color
    }
}

#Preview {
    ProjectList(selectedIds: Binding(projectedValue: .constant(Set<ProjectItem.ID>())))
}
