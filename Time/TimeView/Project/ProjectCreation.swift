//
//  ProjectCreation.swift
//  Time
//
//  Created by A on 20/07/2024.
//

import SwiftUI
import GeneralMacro
import SwiftData

struct ProjectCreation: View {
    typealias VoidFunction = () -> Void
    
    @Environment(\.self) var environment
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var items: [ProjectItem]
    
    /// the project passed by the caller, i.e. to modify it
    @State private var givenProject: ProjectItem?
    
    @State private var name = ""
    @State private var tags = [Tag]()
    @State private var color = Color.randomColor
    @State private var parent = nil as ProjectItem?
    @State private var notes = ""
    
    @State private var detailExpanded: Bool = false
    
    var onCancel: VoidFunction? = nil
    var onCreate: VoidFunction? = nil
    var onUpdate: VoidFunction? = nil
    
    private var persistentIdentifier: PersistentIdentifier?
    
    
    /// create the project
    init(onCancel: VoidFunction? = nil, onCreate: VoidFunction? = nil) {
        self.onCancel = onCancel
        self.onCreate = onCreate
    }
    
    /// edit the project
    init(item: ProjectItem, onCancel: VoidFunction? = nil, onUpdate: VoidFunction? = nil) {
        self.onCancel = onCancel
        self.onUpdate = onUpdate
        givenProject = item
    }
    
    /// edit the project (window)
    init(id: PersistentIdentifier?) {
        self.persistentIdentifier = id
    }
    
    var body: some View {
        VStack { // do not use form for complicated UI
            ScrollView {
                TextField("Name:", text: $name)
                TagSelector(selectedTags: $tags)
                    .frame(height: 100)
                ColorPicker("Color:", selection: $color, supportsOpacity: false)
                Picker("Parent", selection: $parent) {
                    Text("").tag(nil as ProjectItem?)
                    ForEach(items) { item in
                        Text(item.name).tag(item as ProjectItem?)
                    }
                }
                TextField("Notes:", text: $notes)
                if let project = givenProject {
                    DisclosureGroup("Detail", isExpanded: $detailExpanded) {
                        // TODO: auto scroll to this when shown
                        VStack(alignment: .leading) {
                            Text("Created at: \(project.creationTime)")
                            Text("ID: \(project.id)")
                            Text("Parent ID: \(String(describing: project.parent?.id))")
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            HStack {
                Spacer()
                Button("Cancel", action: handleCancel)
                Button(givenProject == nil ? "Create" : "Update", action: handleCreateAndUpdate)
            }
        }
        .padding()
        .onAppear(perform: onAppear)
        .navigationTitle("Project editor - \(name)")
    }
    
    private func onAppear() {
        checkAndFetchProject()
        checkAndCopyGivenProject()
    }
    
    private func checkAndFetchProject() {
        guard let id = persistentIdentifier else {
            return
        }
        givenProject = context.registeredModel(for: id)
    }
    
    private func checkAndCopyGivenProject() {
        if let givenProject = givenProject {
            name = givenProject.name
            tags = givenProject.tags
            color = givenProject.color
            parent = givenProject.parent
            notes = givenProject.notes
        }
    }
    
    private func handleCancel() {
        closeSelf()
    }
    
    private func handleCreateAndUpdate() {
        if givenProject != nil {
            handleUpdate()
        } else {
            handleCreate()
        }
    }
    
    private func handleCreate() {
        createItem()
        onCreate?()
        closeSelf()
    }
    
    private func handleUpdate() {
        updateItem()
        onUpdate?()
        closeSelf()
    }
    
    private func updateItem() {
        if let givenProject = givenProject {
            givenProject.name = name
            givenProject.tags = tags
            setColor(project: givenProject, color: color)
            givenProject.parent = parent
            givenProject.notes = notes
        }
    }
    
    private func createItem() {
        let newProject = ProjectItem(name: name)
        newProject.tags = tags
        setColor(project: newProject, color: color)
        newProject.parent = parent
        newProject.notes = notes
        context.insert(newProject)
        closeSelf()
    }
    
    func setColor(project: ProjectItem, color: Color) { // I don not know why many weird things would happen if you resolve the color in other places, so update the color in this view.
        let resolved = color.resolve(in: environment)
        project.r = resolved.red
        project.g = resolved.green
        project.b = resolved.blue
    }
    
    private func closeSelf() {
        dismiss()
    }
}

#Preview {
    ProjectCreation()
        .modelContainer(for: models, inMemory: false)
}
