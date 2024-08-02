//
//  ItemListView.swift
//  Time
//
//  Created by A on 17/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(ViewModel.self) private var viewModel

    @State var selectedIds: Set<ProjectItem.ID> = .init()
    @State private var searchText: String = ""
    @State private var sortOrder = SortDescriptor(\ProjectItem.accessTime, order: .reverse)
    @State var isCreationViewPresent = false
    @State var isAlertShown = false
    
    #if os(macOS)
    #endif
            
    var body: some View {
        // TODO: change to lazy list
        // TODO: Use navigation split view on large screen devices
        // TODO: Show Keyboard shortcut in menu
        // TODO: allow user to set custom keyboard shortcut
        ProjectList(
            selectedIds: $selectedIds,
            sortParameter: viewModel.sortParameter,
            sortOrder: viewModel.sortOrder
        )
        .sheet(isPresented: $isCreationViewPresent) {
            CreationView {
                dismissCreationView()
            } onCreate: {
                dismissCreationView()
            }
        }
        .alert("Delete \(selectedIds.count) items?", isPresented: $isAlertShown) {
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        }
        .toolbar {
            if !selectedIds.isEmpty {
                Text("\(selectedIds.count) selected")
            }
            Button("Add", systemImage: "plus", action: addItem)
            SortButton()
        }

#if os(macOS)
        .onDeleteCommand(perform: confirmDeleteSelectedItems)
        .onKeyPress(.return, action: {startSelectedProjects(); return .handled})
        .onKeyPress(.space, action: {showSelectedPopover(); return .handled})
#endif
        .searchable(text: $searchText) // TODO: implement advanced search
        .onChange(of: sortOrder, handleSortOrderChange)
    }
    
    private func handleSortOrderChange() {
//        self._items = Query(sort: sortOrder, animation: .default)
    }
    
    func startSelectedProjects() {
        enumerateSelection { project in
            let period = PeriodRecord(project: project)
            context.insert(period)
            period.start()
        }
        selectedIds.removeAll()
    }
    
    func showSelectedPopover() {
        guard selectedIds.count == 1 else {
            return
        }
        enumerateSelection { project in
            project.isPopoverShown = true
        }
    }
    
    func enumerateSelection(block: (ProjectItem) -> Void) {
        try? context.enumerate(ProjectItem.descriptorById(ids: selectedIds), block: block)
    }
        
    func confirmDeleteSelectedItems() {
        isAlertShown = true
    }
    

    
    func dismissCreationView() {
        isCreationViewPresent = false
    }
    
    func addItem() {
        isCreationViewPresent = true
    }
    
    func deleteSelectedItems() {
        try? context.delete(model: ProjectItem.self, where: #Predicate { item in
            selectedIds.contains(item.id)
        })
        selectedIds.removeAll()
    }
    

}

let items = [
    sport
]

#Preview {
    ContentView()
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self])
        .environment(ViewModel())
}
