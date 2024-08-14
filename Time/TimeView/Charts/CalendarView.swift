//
//  CalendarView.swift
//  Time
//
//  Created by A on 14/08/2024.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(filter: PeriodRecordService.getRangedPredicate(start: Calendar.autoupdatingCurrent.dateInterval(of: .weekOfYear, for: .now)!.start, end: .now), animation: .default) private var periods: [PeriodRecord]
    @State private var gridRect: CGRect = .zero
    @State private var cellHeight: CGFloat = 40
    @GestureState private var magnifyBy = 1.0
    private let velocity: CGFloat = 0.1
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                WeekDayHeader(startDate: getStartDate(), endDate: getEndDate(), gridRect: gridRect)
                ScrollView([.vertical]) {
                    HStack {
                        TimeMark()
                        ZStack {
                            CalendarBackgroundGrid()
                                .frame(height: getGridHeight(geometry))
                                .contentShape(.rect)
                                .gesture(tap)
                            CalendarCanvas(periods: periods, start: getStartDate(), end: getEndDate())
                        }
                        .background {
                            GeometryReader { gridGeometry in
                                Color.clear.onChange(of: gridGeometry.frame(in: .named("calendar")), initial: true) {
                                    let rect = gridGeometry.frame(in: .named("calendar"))
                                    gridRect = rect
                                }
                            }
                        }
                    }
                }
            }.coordinateSpace(.named("calendar"))
        }
        .focusable(true)
        .focusEffectDisabled(true)
        .gesture(magnification)
        .onKeyPress(characters: .init(charactersIn: "+_")) { keyPress in
            guard keyPress.modifiers == [.command, .shift] else {
                return .ignored
            }
            switch keyPress.characters {
            case "+":
                increaseCellHeight()
            case "_":
                decreaseCellHeight()
            default:
                return .ignored
            }
            return .handled
        }
    }
    
    var tap: some Gesture {
        SpatialTapGesture()
            .onEnded { event in
                print(event.location)
            }
    }
    
    var magnification: some Gesture {
        MagnifyGesture()
            .updating($magnifyBy) { value, gestureState, transaction in
                print(value)
            }
    } // TODO: study this api
    func increaseCellHeight() {
        cellHeight = cellHeight * (1 + velocity)
    }
    func decreaseCellHeight() {
        cellHeight = cellHeight * (1 - velocity)
    }
    func getGridHeight(_ geometry: GeometryProxy) -> CGFloat {
        let hours: CGFloat = 24
        let height = hours * cellHeight
        return height
    }
    func getStartDate() -> Date {
        return getStartOfWeek()
    }
    func getEndDate() -> Date {
        return getEndOfWeek()
    }
    func getStartOfWeek(oneDayInThatWeek date: Date = .now) -> Date {
        return Calendar.autoupdatingCurrent.dateInterval(of: .weekOfYear, for: date)!.start
    }
    func getEndOfWeek(oneDayInThatWeek date: Date = .now) -> Date {
        return Calendar.autoupdatingCurrent.dateInterval(of: .weekOfYear, for: date)!.end - 1
    }
}

#Preview {
    CalendarView()
}
