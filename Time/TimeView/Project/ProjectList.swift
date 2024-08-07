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
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: [SortDescriptor(\ProjectItem.accessTime, order: .reverse)], animation: .default) var projects: [ProjectItem]
    @Query(PeriodRecord.descriptorLastStopped, animation: .default) var lastStopped: [PeriodRecord]

    @Binding var selectedIds: Set<ProjectItem.ID>
    private var runningItems: [PeriodRecord]
        
    init(
        selectedIds: Binding<Set<ProjectItem.ID>>,
        
        searchText: String = "",
        
        sortParameter: SortParameter = .recentness,
        sortOrder: SortOrder = .reverse,
        
        runningItems: [PeriodRecord]
    ) {
        self._selectedIds = selectedIds
        self.runningItems = runningItems
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
            updateRunningItemsCount()
            if projects.isEmpty {
                let item = ProjectItem(name: "Sample Project")
                let item2 = ProjectItem(name: "Sample Project 2")
                context.insert(item)
                context.insert(item2)
            }
        }
        .onChange(of: runningItems) {
            updateRunningItemsCount()
        }
    }
    
    private func updateRunningItemsCount() {
        viewModel.runningProjectCount = runningItems.count
    }
    
    
    var headerProjects: [ProjectItem] {
        guard !runningItems.isEmpty else {
            if let firstProject = projects.first {
                return [firstProject]
            }
            return []
        }
        return runningItems.map(\.project)
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
        .environment(ViewModel())
}
