//
//  CalendarCanvas.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI

struct CalendarCanvas: View {
    let periods: [PeriodRecord]
    var start: Date
    var end: Date
    private let numberOfDates: Int
    init(periods: [PeriodRecord], start: Date, end: Date) {
        self.periods = periods
        self.start = start
        self.end = end
        self.numberOfDates = Date.datesBetween(startDate: start, endDate: end).count
    }
    var body: some View {
        GeometryReader { geometry in
            ForEach(getIntervalPlots(geometry: geometry), id: \.self) { plot in
                PeriodInCalendarView(period: plot.period)
                    .frame(width: plot.width, height: plot.height)
                    .position(x: plot.x, y: plot.y)
            }
        }
    }
    private func getIntervalPlots(geometry: GeometryProxy) -> [IntervalPlot] {
        let datesBetween = Date.datesBetween(startDate: start, endDate: end)
        let calendar = Calendar.autoupdatingCurrent
        let secondsPerDay: CGFloat = 24 * 60 * 60
        let height = geometry.size.height
        let width = geometry.size.width
        var plots = [IntervalPlot]()
        for period in periods {
            let intervals = period.dailySegments().filter({$0.start >= start && $0.end <= end})
            for interval in intervals {
                let intervalStart =  interval.start
                let intervalEnd = interval.end
                
                let plotHeight = intervalEnd.timeIntervalSince(intervalStart) / secondsPerDay * height
                if plotHeight < 1 {
                    continue
                }
                let plotY = intervalStart.timeIntervalSince(calendar.startOfDay(for: intervalStart)) / secondsPerDay * height + plotHeight / 2
                
                let plotWidth = width / CGFloat(numberOfDates)
                let index = datesBetween.reduce(0, {result, date in date < intervalStart ? result + 1 : result}) - 1
                let plotX = CGFloat(index) * plotWidth + plotWidth / 2
                plots.append(.init(x: plotX, y: plotY, width: plotWidth, height: plotHeight, period: period))
            }
        }
        return plots
    }
}

struct PeriodInCalendarView: View {
    let period: PeriodRecord
    var body: some View {
        period.project.color
    }
}

fileprivate struct IntervalPlot: Hashable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var period: PeriodRecord
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, period: PeriodRecord) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.period = period
    }
}
