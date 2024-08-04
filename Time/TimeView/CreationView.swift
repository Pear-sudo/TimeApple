//
//  CreationView.swift
//  Time
//
//  Created by A on 20/07/2024.
//

import SwiftUI
import GeneralMacro
import SwiftData

struct CreationView: View {
    typealias VoidFunction = () -> Void
    
    @Environment(\.self) var environment
    @Environment(\.modelContext) var context
    
    @Query private var items: [ProjectItem]
    
    @State private var project: ProjectItem
    @State private var color: Color
    @State private var detailExpanded: Bool = false
    
    var onCancel: VoidFunction? = nil
    var onCreate: VoidFunction? = nil
    var onUpdate: VoidFunction? = nil
    
    private var isUpdating = false
    
    init(onCancel: VoidFunction? = nil, onCreate: VoidFunction? = nil) {
        self.onCancel = onCancel
        self.onCreate = onCreate
        
        let item = ProjectItem(name: "")
        project = item
        color = item.color
    }
    
    init(item: ProjectItem, onCancel: VoidFunction? = nil, onUpdate: VoidFunction? = nil) {
        
        self.onCancel = onCancel
        self.onUpdate = onUpdate
        
        project = item
        color = item.color
        
        isUpdating = true
    }
    
    var body: some View {
        VStack { // do not use form for complicated UI
            ScrollView {
                TextField("Name:", text: $project.name)
                TagSelector(selectedTags: $project.tags)
                    .frame(height: 100)
                HStack {
                    ColorPicker("Color:", selection: $color, supportsOpacity: false)
                    Text("\(project.r), \(project.g), \(project.b)")
                }
                Picker("Parent", selection: $project.parent) {
                    Text("").tag(nil as ProjectItem?)
                    ForEach(items) { item in
                        Text(item.name).tag(item as ProjectItem?)
                    }
                }
                TextField("Notes:", text: #nullable(project.notes))
                DisclosureGroup("Detail", isExpanded: $detailExpanded) {
                    // TODO: auto scroll to this when shown
                    VStack(alignment: .leading) {
                        Text("Created at: \(project.creationTime)")
                        Text("ID: \(project.id)")
                        Text("Parent ID: \(String(describing: project.parent?.id))")
                    }
                }
            }
            .scrollIndicators(.hidden)
            HStack {
                Spacer()
                Button("Cancel") {
                    // TODO: do not save when cancel
                    onCancel?()
                }
                if isUpdating {
                    Button("Update") {
                        onUpdate?()
                    }
                } else {
                    Button("Create") {
                        createItem()
                        onCreate?()
                    }
                }
            }
        }
        .onChange(of: color, DelayedExecutor(delay: 1, function: saveColor).callAsFunction)
        .padding()
    }
    
    func createItem() {
        saveColor()
        context.insert(project)
        reset()
    }
    
    func reset(with item: ProjectItem = ProjectItem(name: "")) {
        project = item
        color = Color(red: Double(item.r), green: Double(item.g), blue: Double(item.b))
    }
    
    func saveColor() {
        let resolved = color.resolve(in: environment)
        project.r = resolved.red
        project.g = resolved.green
        project.b = resolved.blue
    }
}

#Preview {
    CreationView()
        .modelContainer(for: models, inMemory: false)
}
