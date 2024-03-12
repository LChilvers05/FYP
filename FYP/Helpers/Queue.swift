//
//  Queue.swift
//  FYP
//
//  Created by Lee Chilvers on 13/02/2024.
//

import Foundation

// a thread safe queue
actor Queue<T> {
    
    private(set) var elements = [T]()
    private(set) var prevOnsetTime = 0.0

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }

    func enqueue(_ element: T) {
        elements.append(element)
    }

    func dequeue() -> T? {
        return isEmpty ? nil : elements.removeFirst()
    }

    func peek() -> T? {
        return elements.first
    }
    
    func removeAll() {
        elements.removeAll()
    }
    
    // for movement buffer
    func set(prevOnsetTime: TimeInterval) {
        self.prevOnsetTime = prevOnsetTime
    }
}
