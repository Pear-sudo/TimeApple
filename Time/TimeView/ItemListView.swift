//
//  ItemListView.swift
//  Time
//
//  Created by A on 17/07/2024.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
    
    @Query var items: [ProjectItem]
    @Query(PeriodRecord.descriptorRunning, animation: .default) var runningItems: [PeriodRecord]
    @Query(PeriodRecord.descriptorLastStopped, animation: .default) var lastStopped: [PeriodRecord]
    
    @Environment(\.modelContext) private var context
    
    @State var isCreationViewPresent = false
    @State var isAlertShown = false
    @State var selections = Set<ProjectItem.ID>()
    @State private var searchText: String = ""
    
    #if os(macOS)
    #endif
    
    private let horizontalSpacing: CGFloat = 8
        
    var body: some View {
        // TODO: change to lazy list
        // TODO: Use navigation split view on large screen devices
        // TODO: Show Keyboard shortcut in menu
        // TODO: allow user to set custom keyboard shortcut
        List(selection: $selections) {
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
        .toolbar {
            if !selections.isEmpty {
                Text("\(selections.count) selected")
            }
            Button("Add", systemImage: "plus", action: addItem)
        }
        .sheet(isPresented: $isCreationViewPresent) {
            CreationView {
                dismissCreationView()
            } onCreate: {
                dismissCreationView()
            }
        }
        .alert("Delete \(selections.count) items?", isPresented: $isAlertShown) {
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        }
#if os(macOS)
        .onDeleteCommand(perform: confirmDeleteSelectedItems)
        .onKeyPress(.return, action: {startSelectedProjects(); return .handled})
        .onKeyPress(.space, action: {showSelectedPopover(); return .handled})
#endif
        .onAppear() {
            if items.first?.parent == nil {
                items.first!.parent = items[1]
            }
        }
        .searchable(text: $searchText) // TODO: implement advanced search
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
    
    private func calculateActiveProjectViewWidth(_ width: CGFloat) -> CGFloat {
        
        let minWidth: CGFloat = 100
        let numberOfPeriods = CGFloat(headerPeriods.count)
        let availableWidth = width - (numberOfPeriods - 1) * horizontalSpacing
        let calculatedWidth = availableWidth / numberOfPeriods
        
        return max(minWidth, calculatedWidth)
    }
    
    func startSelectedProjects() {
        enumerateSelection { project in
            let period = PeriodRecord(project: project)
            context.insert(period)
            period.start()
        }
        selections.removeAll()
    }
    
    func showSelectedPopover() {
        guard selections.count == 1 else {
            return
        }
        enumerateSelection { project in
            project.isPopoverShown = true
        }
    }
    
    func enumerateSelection(block: (ProjectItem) -> Void) {
        try? context.enumerate(ProjectItem.descriptorById(ids: selections), block: block)
    }
        
    func confirmDeleteSelectedItems() {
        isAlertShown = true
    }
    
    func deleteSelectedItems() {
        try? context.delete(model: ProjectItem.self, where: #Predicate { item in
            selections.contains(item.id)
        })
        selections.removeAll()
    }
    
    func dismissCreationView() {
        isCreationViewPresent = false
    }
    
    func addItem() {
        isCreationViewPresent = true
    }
}

let items = [
    sport
]

#Preview {
    ItemListView()
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self])
}
