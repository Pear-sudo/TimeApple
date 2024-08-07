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
    @Environment(\.viewModel) private var viewModel
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: [SortDescriptor(\ProjectItem.accessTime, order: .reverse)], animation: .default) var projects: [ProjectItem]

    @Binding var selectedIds: Set<ProjectItem.ID>
        
    init(
        selectedIds: Binding<Set<ProjectItem.ID>>,
        
        searchText: String = "",
        
        sortParameter: SortParameter = .recentness,
        sortOrder: SortOrder = .reverse
    ) {
        self._selectedIds = selectedIds
        let predicate = ProjectItem.predicate(searchText: searchText)
        switch sortParameter {
        case .recentness:
            _projects = Query(filter: predicate, sort: \.accessTime, order: sortOrder, animation: .default)
        case .name:
            _projects = Query(filter: predicate, sort: \.name, order: sortOrder, animation: .default)
        }
    }

    var body: some View {
        List(selection: $selectedIds) {
            Group {
                StatsOverview()
                    .padding()
                    .background(Color.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 3)
                    .padding(.bottom, 4)
#if os(macOS)
                    .padding(.top, 8)
#endif
                if !projects.isEmpty {
                    ProjectHeader(headerProjects: headerProjects)
                        .shadow(radius: 3)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
                
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5))
                    .fill(Color.backgroundColor)
                    .frame(height: 5)

                ForEach(projects) { item in
                    ProjectViewInList(item: item)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 10)
                        .background(Color.backgroundColor)
                        .foregroundStyle(Color.textColor)
                }
                
                UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 5, bottomTrailing: 5))
                    .fill(Color.backgroundColor)
                    .frame(height: 5)
            }
            .listRowBackground(Color.white.opacity(0))
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 15, bottom: 0, trailing: 15))
        }
#if os(macOS)
        .padding(.bottom, 10)
#endif
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(backgroundColor)
        .animation(.easeIn, value: backgroundColor)
        .onAppear {
            if projects.isEmpty {
                let item = ProjectItem(name: "Sample Project")
                let item2 = ProjectItem(name: "Sample Project 2")
                context.insert(item)
                context.insert(item2)
            }
        }
    }
    
    
    var headerProjects: [ProjectItem] {
        guard periodRecordService.hasActivePeriods() else {
            if let firstProject = projects.first {
                return [firstProject]
            }
            return []
        }
        return periodRecordService.activePeriods.map(\.value.project)
    }
    
    var backgroundColor: Color {
        var color = headerProjects.first?.color ?? Color.accentColor
        color = color.opacity(0.2)
        return color
    }
}

// MARK: - Previews

#Preview {
    Dashboard()
        .modelContainer(for: models)
        .environment(\.viewModel, viewModel)
}
