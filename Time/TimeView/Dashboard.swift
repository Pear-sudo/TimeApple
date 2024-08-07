//
//  ItemListView.swift
//  Time
//
//  Created by A on 17/07/2024.
//

import SwiftUI
import SwiftData

// this view cannot be the main view as the tool bar will not be shown in iOS
struct Dashboard: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.viewModel) private var viewModel
    @Environment(\.viewModel.periodRecordService) private var periodRecordService
            
    var body: some View {
        // TODO: change to lazy list
        // TODO: Show Keyboard shortcut in menu
        // TODO: allow user to set custom keyboard shortcut
        ProjectList(
            searchText: viewModel.searchText,
            sortParameter: viewModel.sortParameter,
            sortOrder: viewModel.sortOrder
        )
    }
}

#Preview {
    Dashboard()
        .modelContainer(for: models)
        .environment(\.viewModel, viewModel)
}
