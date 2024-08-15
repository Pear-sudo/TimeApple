//
//  WeekDayHeader.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI

struct WeekDayHeader: View {
    var startDate: Date
    var endDate: Date
    var gridRect: CGRect
    @State private var headerRect: CGRect = .zero
    private let calendar = Calendar.autoupdatingCurrent
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(calendar.component(.weekOfYear, from: startDate).formatted())
                    .font(.caption.monospacedDigit())
                HStack(spacing: 0) {
                    ForEach(dates, id: \.self) { date in
                        Text(date.formatted(.dateTime.day(.twoDigits).weekday(.abbreviated)))
                            .frame(width: gridRect.width / CGFloat(dates.count), alignment: .center)
                            .foregroundStyle(calendar.isDateInToday(date) ? Color.cyan : .primary)
                    }
                }
                .frame(width: gridRect.width)
                .offset(x: offset, y: 0)
                .background {
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .named("calendar"))) {
                            let rect = geometry.frame(in: .named("calendar"))
                            headerRect = rect
                        }
                    }
                }
                .padding(.vertical, 3)
            }
            Color.secondary
                .opacity(0.5)
                .frame(height: 1)
        }
    }
    
    var offset: CGFloat {
        let gridStart = gridRect.minX
        let headerStart = headerRect.minX
        let delta = gridStart - headerStart
        return delta
    }
    
    var dates: [Date] {
        return Date.datesBetween(startDate: startDate, endDate: endDate)
    }
}

extension Date {
    static func datesBetween(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        
        // Ensure the start date is before or equal to the end date
        guard startDate <= endDate else {
            return dates
        }
        
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
}
