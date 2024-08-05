//
//  ViewModel.swift
//  Time
//
//  Created by A on 01/08/2024.
//

import Foundation
import Combine

@Observable
class ViewModel {
    var sortParameter: SortParameter = .recentness
    var sortOrder: SortOrder = .reverse
    
    var searchText: String = ""
    
    private var timerSubscription: AnyCancellable?
    private var subscriberCount = 0
    
    private var timerPublisher: Timer.TimerPublisher?
    private var timerActions: [UUID: () -> Void] = [:]
    
    private func startTimer() {
        timerPublisher = Timer.publish(every: 1.0, on: .current, in: .common)
        timerSubscription = timerPublisher?
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerFired()
            }
    }
    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        timerPublisher = nil
    }
    
    private func timerFired() {
        Task {
            for action in timerActions.values {
                action()
            }
        }
    }
    
    func subscribe(id: UUID, action: @escaping () -> Void) {
        guard timerActions[id] == nil else {
            print("Id: \(id) already exists, overriding...")
            timerActions[id] = action
            return
        }
        print("Subscribing id: \(id)")
        subscriberCount += 1
        timerActions[id] = action
        if subscriberCount == 1 {
            startTimer()
        }
    }
    
    func unsubscribe(id: UUID) {
        guard timerActions.removeValue(forKey: id) != nil else {
            print("Cannot unsubscribe, id not found: \(id)")
            return
        }
        print("Unsubscribing id: \(id)")
        subscriberCount -= 1
        if subscriberCount == 0 {
            stopTimer()
        }
    }
}
