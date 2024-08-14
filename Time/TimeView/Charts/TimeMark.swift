//
//  TImeMark.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI

struct TimeMark: View {
    var marks: [Int] = Array(0...23)
    var body: some View {
        GeometryReader { geometry in
            ForEach(marks, id: \.self) { mark in
                Text(mark.formatted(.number.precision(.integerLength(2))))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .offset(x: 0, y: getOffset(geometry: geometry, index: mark))
                    .fixedSize()
            }
        }.fixedSize(horizontal: true, vertical: false)
    }
    func getOffset(geometry: GeometryProxy, index: Int) -> CGFloat {
        let height = geometry.size.height
        let cellHeight = height / CGFloat(marks.count)
        let offset = cellHeight * CGFloat(index)
        return offset
    }
}

#Preview {
    TimeMark()
}
