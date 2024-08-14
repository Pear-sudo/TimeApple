//
//  CalendarBackgroundGrid.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI

struct CalendarBackgroundGrid: View {
    
    var columnCount = 7
    var rowCount = 24
    
    var skipBeginX = true
    var skipEndX = true
    var skipBeginY = true
    var skipEndY = true
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                let rowHeight = getRowHeight(geometry)
                let rowWidth = getRowWidth(geometry)
                for yIndex in 0...columnCount {
                    if shouldSkipThisY(yIndex) {
                        continue
                    }
                    let columnX = CGFloat(yIndex) * rowWidth
                    path.move(to: .init(x: columnX, y: 0))
                    path.addLine(to: .init(x: columnX, y: height))
                }
                for xIndex in 0...rowCount {
                    if shouldSkipThisX(xIndex) {
                        continue
                    }
                    let rowY = CGFloat(xIndex) * rowHeight
                    path.move(to: .init(x: 0, y: rowY))
                    path.addLine(to: .init(x: width, y: rowY))
                }
            }
            .stroke(.secondary.opacity(0.5))
        }
    }
    
    func shouldSkipThisX(_ xIndex: Int) -> Bool {
        if skipBeginX && xIndex == 0 {
            return true
        }
        if skipEndX && xIndex == rowCount {
            return true
        }
        return false
    }
    
    func shouldSkipThisY(_ yIndex: Int) -> Bool {
        if skipBeginY && yIndex == 0 {
            return true
        }
        if skipEndY && yIndex == columnCount {
            return true
        }
        return false
    }
    
    func getRowHeight(_ geometry: GeometryProxy) -> CGFloat {
        let height = geometry.size.height
        let rowHeight = height / CGFloat(rowCount)
        return rowHeight
    }
    
    func getRowWidth(_ geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width
        let rowWidth = width / CGFloat(columnCount)
        return rowWidth
    }
}

#Preview {
    CalendarBackgroundGrid()
}
