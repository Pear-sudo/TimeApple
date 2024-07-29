//
//  Util.swift
//  Time
//
//  Created by A on 21/07/2024.
//

import Foundation

class DelayedExecutor {
    private var delay: TimeInterval
    private var function: () -> Void
    private var timer: Timer?
    
    init(delay: Int, function: @escaping () -> Void) {
        self.delay = TimeInterval(delay)
        self.function = function
    }
    
    func callAsFunction() {
        // Invalidate any existing timer
        timer?.invalidate()
        
        // Schedule a new timer
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.function()
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

func RadixTransform<T: BinaryInteger>(source: T, radices: [T]) -> [T] {
    var source = source
    var result: [T] = []
    for r in radices {
        let remainder = source % r
        result.append(remainder)
        source = source / r
    }
    result.append(source)
    result.reverse()
    return result
}
