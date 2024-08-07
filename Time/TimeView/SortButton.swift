//
//  SortButton.swift
//  Time
//
//  Created by A on 01/08/2024.
//

import SwiftUI

struct SortButton: View {
    @Environment(\.viewModel) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        Menu {
            Picker("Sort Order", selection: $viewModel.sortOrder) {
                ForEach([SortOrder.forward, .reverse], id: \.self) { order in
                    Text(order.name)
                }
            }
            Picker("Sort By", selection: $viewModel.sortParameter) {
                ForEach(SortParameter.allCases) { parameter in
                    Text(parameter.name)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .pickerStyle(.inline)
    }
}

extension SortOrder {
    var name: String {
        switch self {
        case .forward: "Forward"
        case .reverse: "Reverse"
        }
    }
}

#Preview {
    SortButton()
        .environment(\.viewModel, viewModel)
}
