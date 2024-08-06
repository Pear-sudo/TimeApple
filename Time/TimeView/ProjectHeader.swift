//
//  ProjectsHeader.swift
//  Time
//
//  Created by A on 06/08/2024.
//

import SwiftUI

struct ProjectHeader: View {
    
    private var headerProjects: [ProjectItem]
    
    private let horizontalSpacing: CGFloat = 8
    
    init(headerProjects: [ProjectItem]) {
        self.headerProjects = headerProjects
    }
    
    var body: some View {
        ZStack {
            ProjectViewInHeader(project: headerProjects.first!, isDummy: true)
                .disabled(true)
                .hidden()
            GeometryReader { geometry in
                ScrollView([.horizontal]) {
                    HStack(spacing: horizontalSpacing) {
                        ForEach(headerProjects) { project in
                            ProjectViewInHeader(project: project)
                                .frame(minWidth: calculateActiveProjectViewWidth(geometry.size.width))
                        }
                    }
                }
                .scrollIndicators(.never, axes: [.horizontal, .vertical]) // do not use hidden; it will show white space on macos, and that's the indicator
                .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .listRowBackground(Color.white.opacity(0)) // note that this view is part of the surrounding list
        .listRowSeparator(.hidden)
        .shadow(radius: 3)
    }
    
    private func calculateActiveProjectViewWidth(_ width: CGFloat) -> CGFloat {
        
        let minWidth: CGFloat = 100
        let numberOfPeriods = CGFloat(headerProjects.count)
        let availableWidth = width - (numberOfPeriods - 1) * horizontalSpacing
        let calculatedWidth = availableWidth / numberOfPeriods
        
        return max(minWidth, calculatedWidth)
    }
}
