//
//  ItemListView.swift
//  Time
//
//  Created by A on 17/07/2024.
//

import SwiftUI
import SwiftData

// this view cannot be the main view as the tool bar will not be shown in iOS
struct Dashboard: View {
    
    @Environment(\.modelContext) private var context
    @Environment(ViewModel.self) private var viewModel
    
    @Query(PeriodRecord.descriptorRunning, animation: .default) var runningItems: [PeriodRecord]

    @State var selectedIds: Set<ProjectItem.ID> = .init()
    @State private var sortOrder = SortDescriptor(\ProjectItem.accessTime, order: .reverse)
    @State var isCreationViewPresent = false
    @State var isAlertShown = false
    
    #if os(macOS)
    #endif
            
    var body: some View {
        @Bindable var viewModel = viewModel
        // TODO: change to lazy list
        // TODO: Use navigation split view on large screen devices
        // TODO: Show Keyboard shortcut in menu
        // TODO: allow user to set custom keyboard shortcut
        ProjectList(
            selectedIds: $selectedIds,
            searchText: viewModel.searchText,
            sortParameter: viewModel.sortParameter,
            sortOrder: viewModel.sortOrder,
            runningItems: runningItems
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
        .onKeyPress(.space, action: showSelectedPopover)
#endif
        .searchable(text: $viewModel.searchText) // TODO: implement advanced search
        .onChange(of: sortOrder, handleSortOrderChange)
    }
    
    private func handleSortOrderChange() {
//        self._items = Query(sort: sortOrder, animation: .default)
    }
    
    func startSelectedProjects() {
        let runningProjects = runningItems.map(\.project)
        enumerateSelection { project in
            if runningProjects.contains(project) {
                return // we do not allow one project to have two active instances
            }
            project.start(context: context)
        }
        selectedIds.removeAll()
    }
    
    func showSelectedPopover() -> KeyPress.Result {
        guard selectedIds.count == 1 else {
            return .ignored
        }
        guard let item = try? context.fetch(ProjectItem.descriptorById(ids: selectedIds)).first else {
            return .ignored
        }
        guard !item.isPopoverShown else {
            return .ignored
        }
        item.isPopoverShown = true
        return .handled
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
    Dashboard()
        .modelContainer(for: models)
        .environment(ViewModel())
}
