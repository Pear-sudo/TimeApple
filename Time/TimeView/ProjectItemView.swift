//
//  ProjectEntryView.swift
//  Time
//
//  Created by A on 10/07/2024.
//

import SwiftUI

struct ProjectItemView: View {
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
        #endif
        .padding()
        .background(item.color)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
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
}
