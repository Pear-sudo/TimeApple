//
//  ParentProjectPicker.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI
import SwiftData

struct ParentProjectPicker: View {
    @Binding var project: ProjectItem
    @State private var pickerIsShown = false
    var body: some View {
        ProjectViewWithoutTime(project: project)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .sheet(isPresented: $pickerIsShown) {
            ProjectPicker(project: $project)
        }
        .onTapGesture {
            pickerIsShown = true
        }
    }
}

struct ProjectPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var project: ProjectItem
    @Query private var projects: [ProjectItem]
    @State private var searchText: String = ""
    var body: some View {
        VStack {
            SearchField(searchText: $searchText)
                .padding(.bottom, 5)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(projectsToShow) { project in
                        ProjectViewWithoutTime(project: project)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(.rect)
                            .onTapGesture {
                                self.project = project
                                dismiss()
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .background(Color.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .padding(3)
    }
    private var projectsToShow: [ProjectItem] {
        return projects
            .filter({searchText == "" ? true : $0.name.localizedCaseInsensitiveContains(searchText)})
    }
}

struct SearchField: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextFieldWithUnderline(hint: "Search", text: $searchText)
        }
    }
}

struct ProjectViewWithoutTime: View {
    var project: ProjectItem
    var body: some View {
        ShortLayout {
            Capsule()
                .fill(project.color)
                .frame(width: 4)
            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.title3)
                Text(project.parent?.name ?? "")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 3)
        }
    }
}
