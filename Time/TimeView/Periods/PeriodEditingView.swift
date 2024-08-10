//
//  PeriodEditingView.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI
import SwiftData

struct PeriodEditingView: View {
    var period: PeriodRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack() {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                ParentProjectPicker()
            }
            HStack {
                Image(systemName: "pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                ProjectNote()
            }
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                TimeIntervalPicker()
            }
            HStack {
                Image(systemName: "calendar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                ProjectDatePicker()
            }
            HStack {
                Image(systemName: "timer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                VStack(alignment: .leading) {
                    Text("Duration")
                    DurationView(duration: period.duration!)
                }
            }
            Spacer()
            SubmitControls()
        }
    }
}

#Preview {
    struct ViewWrapper: View {
        var container: ModelContainer
        var context: ModelContext
        @State var period: PeriodRecord? = nil
        init() {
            let schema = Schema(models)
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
            context = ModelContext(container)
        }
        var body: some View {
            PeriodEditingView(period: setUpData())
                .modelContext(context)
        }
        func setUpData() -> PeriodRecord {
            let project = ProjectItem(name: "Programming")
            context.insert(project)
            let period = PeriodRecord(project: project)
            period.startTime = .now - 9632
            period.endTime = .now
            context.insert(period)
            self.period = period
            return period
        }
    }
    return ViewWrapper()
}
