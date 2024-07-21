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
    
    @Environment(\.modelContext) private var context
    
    @State var isCreationViewPresent = false
    @State var isAlertShown = false
    @State var selections = Set<ProjectItem.ID>()
    
    var body: some View {
        List(selection: $selections) {
            ForEach(items) {item in
                ProjectItemView(item: item)
                    .listRowSeparator(.hidden)
            }
        }
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
        #endif
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
        .modelContainer(for: ProjectItem.self)
}
