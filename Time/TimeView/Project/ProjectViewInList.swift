//
//  ProjectEntryView.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI

struct ProjectViewInList: View {
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif
    @Environment(\.modelContext) private var context
    
    @State var item: ProjectItem
    @State private var isExpanded = false
    @State private var isDetailShown = false
    var body: some View {
        HStack {
            VStack {
                Text(item.name)
                Text(item.parent?.name ?? "")
                Text(timeString)
            }
            Button("more", systemImage: isExpanded ? "chevron.up" : "chevron.down", action: expand)
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
            #if os(iOS)
            Button("more", systemImage: "ellipsis", action: more)
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
            #endif
        }
        .sheet(isPresented: $isDetailShown) {
            ProjectCreation(item: item) {
                hideDetails()
            } onUpdate: {
                hideDetails()
            }
        }
        #if os(macOS)
        .contextMenu {
            Button("Details") {
                openWindow(id: WindowId.projectEditor.rawValue, value: item.id)
            }
        }
        .popover(isPresented: $item.isPopoverShown, content: {
            ProjectCreation(item: item) {
                item.isPopoverShown = false
            } onUpdate: {
                item.isPopoverShown = false
            }
        })
        #endif
        .padding()
        .frame(maxWidth: .infinity)
        .background(item.color)
#if os(iOS)
        .onTapGesture {
            item.start(context: context)
        }
#endif
        
    }
    
    private func hideDetails() {
        isDetailShown = false
    }
    
    private func expand() {
        isExpanded.toggle()
    }
    private func more() {
        
    }
    var timeString: String {
        ""
    }
}

let sport = ProjectItem(name: "Sport")

#Preview {
    ProjectViewInList(item: sport)
        .padding()
        .environment(ViewModel())
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self], isUndoEnabled: false)
}
