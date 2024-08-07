//
//  ActiveProjectView.swift
//  Time
//
//  Created by A on 28/07/2024.
//

import SwiftUI
import SwiftData
import Combine

struct ProjectViewInHeader: View {
    @Environment(\.modelContext) var context
    @Environment(ViewModel.self) private var viewModel
    
    @State var project: ProjectItem
    @State var elapsedTimeString = "0s"
    
    @State var animationTrigger = false
    @State var viewID = UUID()
    
    @Query(filter: #Predicate<PeriodRecord> { period in
        !(period.startTime != nil && period.endTime != nil)
    }, animation: .default) private var periods: [PeriodRecord]
    
    private let isDummy: Bool // if this view is hidden and for layout purpose
        
    init(project: ProjectItem, isDummy: Bool = false) {
        self.project = project
        self.isDummy = isDummy
        
        let id = project.id // make sure id is a constant, project.id won't work as it is indeed a computed var
        self._periods = Query(
            filter: #Predicate<PeriodRecord> { period in
                period.project.id == id && !(period.startTime != nil && period.endTime != nil)
            },
            animation: .default
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(project.name)
                        .bold()
                        .font(.title2)
                    Text(project.parent?.name ?? " ") // some character is necessary
                        .padding(.top, 5)
                }
                .padding(.leading, 10)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(elapsedTimeString)
                        .font(.callout.monospaced())
                        .opacity(hasRunningPeriod ? 1 : 0)
                        .padding(.bottom, 5)
                        .animation(.easeIn, value: hasRunningPeriod)
//                        .animation(.bouncy, value: elapsedTimeString)
                    Image(systemName: hasRunningPeriod ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .animation(.easeIn, value: hasRunningPeriod)
                        .shadow(radius: 10)
                }
                Circle()
                    .frame(width: 10, height: 10)
                    .padding(.trailing, 5)
                    .opacity(animationTrigger ? 1 : 0)
                    .animation(hasRunningPeriod ? .linear(duration: 1) : .easeIn, value: animationTrigger)
            }
            .onChange(of: hasRunningPeriod) {
                if hasRunningPeriod {
                    elapsedTimeString = "0s" // I intentionally reset the value here; if you reset in stopTimer, the user will see it when it is disappearing
                    startTimer()
                } else {
                    stopTimer()
                }
            }
            .onAppear {
                if hasRunningPeriod {
                    elapsedTimeString = period!.elapsedTime
                    startTimer()
                }
            }
            .onDisappear {
                stopTimer()
            }
            .padding(.vertical, 10)
            .background(project.color)
            .onTapGesture {
                if hasRunningPeriod {
                    period!.endTime = Date()
                } else {
                    let p = PeriodRecord(project: project)
                    context.insert(p)
                    p.start()
                }
            }
            HStack {
                Button("Add note") {
                    
                }
                .fixedSize()
                .padding(.trailing ,20)
                Button("Edit entry") {
                    
                }
                .fixedSize()
                Spacer()
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundStyle(.blue)
            .padding(.all, 10)
            .frame(maxWidth: .infinity)
            .background(Color.backgroundColor) // the order matters, set size first, then color
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    private func startTimer() {
        guard !isDummy else {
            return
        }
//        print("Start: \(Thread.current)")
        viewModel.subscribe(id: viewID) {
//            print("...: \(Thread.current)")
            guard let period = period else {
                return
            }
            elapsedTimeString = period.elapsedTime
            animationTrigger.toggle()
        }
    }
    
    private func stopTimer() {
        guard !isDummy else {
            return
        }
//        print("Stop: \(Thread.current)")
        viewModel.unsubscribe(id: viewID)
        
        animationTrigger = false
    }
    
    private var hasRunningPeriod: Bool {
        !periods.isEmpty
    }
    
    private var period: PeriodRecord? {
        return periods.first
    }
    
//    private var period: PeriodRecord {
//        
//    }
}

struct ActiveProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .modelContainer(
                for: [ProjectItem.self, PeriodRecord.self],
                inMemory: true
            )
            .environment(ViewModel())
            .padding()
    }
    struct PreviewWrapper: View {
        @Query var projects: [ProjectItem]
        @Environment(\.modelContext) var context
        var body: some View {
            VStack {
                if !projects.isEmpty {
                    ProjectViewInHeader(project: projects.first!)
                }
            }
            .onAppear() {
                let project = ProjectItem(name: "Test")
                let parent = ProjectItem(name: "This is a parent project")
                context.insert(parent) // this is necessary, since the lib do not store the parent directly to the child struct, a property wrapper will perform a query based on some reference value
                project.parent = parent
                context.insert(project)
                let p = PeriodRecord(project: project)
                p.startTime = Date()
                context.insert(p)
            }
        }
    }
}
