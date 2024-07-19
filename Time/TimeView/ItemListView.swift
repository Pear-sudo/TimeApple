//
//  ItemListView.swift
//  Time
//
//  Created by A on 17/07/2024.
//

import SwiftUI

struct ItemListView: View {
    @State var items: [ProjectItem]
    var body: some View {
        List {
            ForEach(items) {item in
                ProjectItemView(projectItem: item)
            }
        }
    }
}

let items = [
    sport
]

#Preview {
    ItemListView(items: items)
}
