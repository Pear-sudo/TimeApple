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
            Overview()
            if !projects.isEmpty {
                ProjectsHeader(headerProjects: headerProjects)
            }
            Section {
                ForEach(projects) {item in
                    ProjectItemView(item: item)
                        .listRowSeparator(.hidden)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    //  listRowBackground is not same as background; it impacts the insects; and it stack on top of the background
                        .listRowBackground(Color.white.opacity(0))
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

struct ProjectsHeader: View {
    
    private var headerProjects: [ProjectItem]
    
    private let horizontalSpacing: CGFloat = 8
    
    init(headerProjects: [ProjectItem]) {
        self.headerProjects = headerProjects
    }
    
    var body: some View {
        ZStack {
            ProjectHeaderView(project: headerProjects.first!, isDummy: true)
                .disabled(true)
                .hidden()
            GeometryReader { geometry in
                ScrollView([.horizontal]) {
                    HStack(spacing: horizontalSpacing) {
                        ForEach(headerProjects) { project in
                            ProjectHeaderView(project: project)
                                .frame(minWidth: calculateActiveProjectViewWidth(geometry.size.width))
                        }
                    }
                }
                .scrollIndicators(.never, axes: [.horizontal, .vertical]) // do not use hidden; it will show white space on macos, and that's the indicator
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .listRowBackground(Color.white.opacity(0)) // note that this view is part of the surrounding list
        .listRowSeparator(.hidden)
        .shadow(radius: 3)
    }
    
    private func calculateActiveProjectViewWidth(_ width: CGFloat) -> CGFloat {
        
        let minWidth: CGFloat = 100
        let numberOfPeriods = CGFloat(headerProjects.count)
        let availableWidth = width - (numberOfPeriods - 1) * horizontalSpacing
        let calculatedWidth = availableWidth / numberOfPeriods
        
        return max(minWidth, calculatedWidth)
    }
}

// MARK: - Previews

#Preview {
    DetailView()
        .modelContainer(for: models)
        .environment(ViewModel())
}
