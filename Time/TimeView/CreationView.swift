//
//  CreationView.swift
//  Time
//
//  Created by A on 20/07/2024.
//

import SwiftUI
import GeneralMacro

struct CreationView: View {
    typealias VoidFunction = () -> Void
    
    @Environment(\.self) var environment
    @Environment(\.modelContext) var context
    
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
        Form {
            ScrollView {
                TextField("Name:", text: $project.name)
                HStack {
                    ColorPicker("Color:", selection: $color, supportsOpacity: false)
                    Text("\(project.r), \(project.g), \(project.b)")
                }
                TextField("Notes:", text: #nullable(project.notes))
                DisclosureGroup("Detail", isExpanded: $detailExpanded) {
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
}
