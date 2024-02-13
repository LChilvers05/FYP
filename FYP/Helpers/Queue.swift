//
//  Queue.swift
//  FYP
//
//  Created by Lee Chilvers on 13/02/2024.
//

import Foundation

struct Queue<T> {
    
    private var elements = [T]()

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
    }

    mutating func dequeue() -> T? {
        return isEmpty ? nil : elements.removeFirst()
    }

    func peek() -> T? {
        return elements.first
    }
}
