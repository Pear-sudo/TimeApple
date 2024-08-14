//
//  TabViewNavigation.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI

struct TabViewNavigation: View {
    var body: some View {
        TabView {
            ProjectSummary()
                .tabItem {
                    Label("Summary", systemImage: "chart.pie")
                }
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    TabViewNavigation()
}
