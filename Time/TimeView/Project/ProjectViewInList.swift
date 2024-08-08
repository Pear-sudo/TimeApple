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
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
    
    @State var item: ProjectItem
    @State private var isExpanded = false
    @State private var isDetailShown = false
    var body: some View {
        HStack {
            ColorBar(color: item.color)
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.title2)
                Text(item.parent?.name ?? "")
                Text(timeString)
            }
            .padding(.vertical, 10)
            .fixedSize()
            Spacer()
            Button("more", systemImage: isExpanded ? "chevron.up" : "chevron.down", action: expand)
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
#if os(iOS)
            Button("more", systemImage: "ellipsis", action: more)
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
#endif
        }
        .fixedSize(horizontal: false, vertical: true)
        .sheet(isPresented: $isDetailShown) {
            ProjectCreation(item: item)
        }
        .frame(maxWidth: .infinity)
#if os(macOS)
        .contextMenu {
            Button("Details") {
                openWindow(id: WindowId.projectEditor.rawValue, value: item.persistentModelID)
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
#if os(iOS)
        .onTapGesture(perform: onTap)
#endif
        
    }
    
    private func expand() {
        isExpanded.toggle()
    }
    
    private func more() {
        
    }
    
    private func onTap() {
        periodRecordService.start(project: item)
    }
    
    var timeString: String {
        ""
    }
}

struct ColorBar: View {
    private var color: Color
    init(color: Color) {
        self.color = color
    }
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: 6)
    }
}

let sport = ProjectItem(name: "Sport")

#Preview {
    ProjectViewInList(item: sport)
        .border(.white)
        .padding()
        .environment(\.viewModel, viewModel)
        .modelContainer(for: [ProjectItem.self, PeriodRecord.self], isUndoEnabled: false)
}
