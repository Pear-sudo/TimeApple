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
    @State var period: PeriodRecord
    @State var elapsedTimeString = "0s"
    
    @State var animationTrigger = false
    @State private var timerSubscription: AnyCancellable?
    
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
                VStack(alignment: .trailing, spacing: 0) {
                    Text(elapsedTimeString)
                        .font(.callout.monospaced())
                        .opacity(isRunning ? 1 : 0)
                        .padding(.bottom, 5)
                        .animation(.easeIn, value: isRunning)
                        .animation(.bouncy, value: elapsedTimeString)
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .animation(.easeIn, value: isRunning)
                }
                Circle()
                    .frame(width: 10, height: 10)
                    .padding(.trailing, 5)
                    .opacity(animationTrigger ? 1 : 0)
                    .animation(isRunning ? .linear(duration: 1) : .easeIn, value: animationTrigger)
            }
            .onChange(of: isRunning) {
                if isRunning {
                    elapsedTimeString = "0s" // I intentionally reset the value here; if you reset in stopTimer, the user will see it when it is disappearing
                    startTimer()
                } else {
                    stopTimer()
                }
            }
            .onAppear {
                if isRunning {
                    elapsedTimeString = "0s"
                    startTimer()
                }
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
                    p.start()
                    context.insert(p)
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
        stopTimer()
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { time in
                elapsedTimeString = elapsedTime
                animationTrigger.toggle()
            }
    }
    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        
        animationTrigger = false
    }
    
    private var project: ProjectItem {
        period.project
    }
    
    private var isRunning: Bool {
        period.isRunning
    }
    
    private var elapsedTime: String {
        guard var interval = period.startTime?.timeIntervalSinceNow else {
            return ""
        }
        interval = abs(interval)
        let results = RadixTransform(source: Int(interval), radices: [60, 60, 24])
        let components = [
            (results[0], "d"),
            (results[1], "h"),
            (results[2], "m"),
            (results[3], "s")
        ]
        
        if let firstNonZeroIndex = components.firstIndex(where: { $0.0 != 0 }) {
            let nonZeroComponents = components[firstNonZeroIndex...]
            return nonZeroComponents.map { "\($0.0)\($0.1)" }.joined()
        }

        return "0s"
    }
}

struct ActiveProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .modelContainer(
                for: [ProjectItem.self, PeriodRecord.self],
                inMemory: true
            )
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
