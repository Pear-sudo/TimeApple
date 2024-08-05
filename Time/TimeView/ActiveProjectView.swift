//
//  ActiveProjectView.swift
//  Time
//
//  Created by A on 28/07/2024.
//

import SwiftUI
import SwiftData
import Combine

struct ActiveProjectView: View {
    @Environment(\.modelContext) var context
    @Environment(ViewModel.self) private var viewModel
    
    @State var period: PeriodRecord
    @State var elapsedTimeString = "0s"
    
    @State var animationTrigger = false
    @State var viewID = UUID()
    
    private let isDummy: Bool // if this view is hidden and for layout purpose
        
    init(period: PeriodRecord, isDummy: Bool = false) {
        self.period = period
        self.isDummy = isDummy
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
                        .opacity(period.isRunning ? 1 : 0)
                        .padding(.bottom, 5)
                        .animation(.easeIn, value: period.isRunning)
//                        .animation(.bouncy, value: elapsedTimeString)
                    Image(systemName: period.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .animation(.easeIn, value: period.isRunning)
                        .shadow(radius: 10)
                }
                Circle()
                    .frame(width: 10, height: 10)
                    .padding(.trailing, 5)
                    .opacity(animationTrigger ? 1 : 0)
                    .animation(period.isRunning ? .linear(duration: 1) : .easeIn, value: animationTrigger)
            }
            .onChange(of: period.isRunning) {
                if period.isRunning {
                    elapsedTimeString = "0s" // I intentionally reset the value here; if you reset in stopTimer, the user will see it when it is disappearing
                    startTimer()
                } else {
                    stopTimer()
                }
            }
            .onAppear {
                if period.isRunning {
                    elapsedTimeString = period.elapsedTime
                    startTimer()
                }
            }
            .onDisappear {
                stopTimer()
            }
            .padding(.vertical, 10)
            .background(period.project.color)
            .onTapGesture {
                if period.isPending {
                    period.startTime = Date()
                } else if period.isRunning {
                    period.endTime = Date()
                } else if period.isStopped {
                    let p = PeriodRecord(project: period.project)
                    context.insert(p)
                    p.start()
                    period = p
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
            .background(.white) // the order matters, set size first, then color
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
    
    private var project: ProjectItem {
        period.project
    }
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
                p.startTime = Date()
                context.insert(p)
            }
        }
    }
}
