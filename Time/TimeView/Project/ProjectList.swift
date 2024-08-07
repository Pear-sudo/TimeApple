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
            StatsOverview()
                .padding()
                .background(Color.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(.bottom, 5)
                .shadow(radius: 3)
            if !projects.isEmpty {
                ProjectHeader(headerProjects: headerProjects)
                    .padding(.bottom, 5)
                    .shadow(radius: 3)
            }
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5))
                .fill(Color.backgroundColor)
                .frame(height: 5)
                .listRowInsets(.init())
            ForEach(projects) { item in
                ProjectViewInList(item: item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)
                    .background(Color.backgroundColor)
                    .foregroundStyle(Color.textColor)
                //  listRowBackground is not same as background; it impacts the insects; and it stack on top of the background
                    .listRowBackground(Color.white.opacity(0))
            }
            UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 5, bottomTrailing: 5))
                .fill(Color.backgroundColor)
                .frame(height: 5)
                .listRowInsets(.init())
        }
        .environment(\.defaultMinListRowHeight, 0)
        .padding(10)
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
