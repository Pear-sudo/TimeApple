//
//  PeriodEditingView.swift
//  Time
//
//  Created by A on 10/08/2024.
//

import SwiftUI
import SwiftData

struct PeriodEditingView: View {
    @Bindable var period: PeriodRecord
    @State private var cachedPeriod = PeriodRecordSkeleton()
    init(period: Bindable<PeriodRecord>) {
        self._period = period
//        self.cachedPeriod = period.wrappedValue.skeleton
    }
    var body: some View {
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 10) {
                GridRow() {
                    Image(systemName: "folder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    ParentProjectPicker()
                }
                GridRow {
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    ProjectNote(text: $cachedPeriod.notes)
                }
                GridRow {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    TimePicker("From", date: $cachedPeriod.startTime)
                    TimePicker("To", date: $cachedPeriod.endTime)
                }
                GridRow {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    ProjectDatePicker(date: $cachedPeriod.startTime)
                }
                GridRow {
                    Image(systemName: "timer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text("Duration")
                            .foregroundStyle(.secondary)
                        DurationView(duration: period.duration!)
                    }
                }
            }
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button("Delete", role: .destructive) {
                    
                }
                Spacer()
                Button("Cancel") {
                    
                }
                Button("OK") {
                    
                }
                .padding(.leading)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Entry")
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
            @Bindable var period = setUpData()
            PeriodEditingView(period: $period)
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
