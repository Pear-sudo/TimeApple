//
//  ActiveProjectView.swift
//  Time
//
//  Created by A on 28/07/2024.
//

import SwiftUI
import SwiftData

struct ActiveProjectView: View {
    @Environment(\.modelContext) var context
    @State var period: PeriodRecord
    
    init(period: PeriodRecord) {
        self.period = period
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(project.name)
                        .bold()
                        .font(.title2)
                    if let parent = project.parent {
                        Text(parent.name)
                            .padding(.top, 5)
                    }
                }
                .padding(.leading, 10)
                Spacer()
                VStack(spacing: 0) {
                    Text("Time")
                        .opacity(isRunning ? 1 : 0)
                        .padding(.bottom, 5)
                        .animation(.easeIn, value: isRunning)
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .animation(.easeIn, value: isRunning)
                }
                Circle()
                    .frame(width: 10, height: 10)
                    .padding(.trailing, 5)
                    .opacity(isRunning ? 1 : 0)
                    .animation(.easeIn, value: isRunning)
            }
            .padding(.vertical, 10)
            .background(period.project.color)
            .onTapGesture {
                if period.isPending {
                    period.beginTime = Date()
                } else if period.isRunning {
                    period.endTime = Date()
                } else if period.isStopped {
                    let p = PeriodRecord(project: period.project)
                    p.start()
                    context.insert(p)
                    period = p
                }
            }
            HStack {
                Button("Add note") {
                    
                }
                .padding(.trailing ,20)
                Button("Edit entry") {
                    
                }
                Spacer()
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundStyle(.blue)
            .padding(.all, 10)
            .frame(maxWidth: .infinity)
            .background(.white) // the order matters, set size first, then color
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    private var project: ProjectItem {
        period.project
    }
    
    private var isRunning: Bool {
        period.isRunning
    }
}

struct ActiveProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .modelContainer(
                for: [ProjectItem.self, PeriodRecord.self],
                inMemory: true
            )
            .frame(width: 300, height: 300)
            .padding()
    }
    struct PreviewWrapper: View {
        @Query var periods: [PeriodRecord]
        @Environment(\.modelContext) var context
        var body: some View {
            VStack {
                if !periods.isEmpty {
                    ActiveProjectView(period: periods.first!)
                }
            }
            .onAppear() {
                let project = ProjectItem(name: "Test")
                let parent = ProjectItem(name: "This is a parent project")
                context.insert(parent) // this is necessary, since the lib do not store the parent directly to the child struct, a property wrapper will perform a query based on some reference value
                project.parent = parent
                context.insert(project)
                let p = PeriodRecord(project: project)
                p.beginTime = Date()
                context.insert(p)
            }
        }
    }
}
