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
    @Query(PeriodRecord.descriptorLastStopped) var lastStopped: [PeriodRecord]
    
    @Environment(\.modelContext) private var context
    
    @State var isCreationViewPresent = false
    @State var isAlertShown = false
    @State var selections = Set<ProjectItem.ID>()
    
    @State var scrollId: ProjectItem.ID?
        
    var body: some View {
        List(selection: $selections) {
            ForEach(headerPeriods) { period in
                ActiveProjectView(period: period)
                    .shadow(radius: 3)
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
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
        .onKeyPress(.space, action: startSelectedProjects)
#endif
        .onAppear() {
            if items.first?.parent == nil {
                items.first!.parent = items[1]
            }
        }
        .onChange(of: scrollId) {
            print(scrollId ?? "")
        }
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
    
    func startSelectedProjects() -> KeyPress.Result {
        try? context.enumerate(ProjectItem.descriptorById(ids: selections)) { project in
            let period = PeriodRecord(project: project)
            context.insert(period)
            period.start()
        }
        selections.removeAll()
        return .handled
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
