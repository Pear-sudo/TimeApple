//
//  ProjectEntryView.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI

struct ProjectItemView: View {
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
            CreationView(item: item) {
                hideDetails()
            } onUpdate: {
                hideDetails()
            }
        }
        #if os(macOS)
        .contextMenu {
            Button("Details") {
                isDetailShown = true
            }
        }
        .popover(isPresented: $item.isPopoverShown, content: {
            CreationView(item: item) {
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
    ProjectItemView(item: sport)
        .padding()
        .environment(ViewModel())
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self], isUndoEnabled: false)
}
