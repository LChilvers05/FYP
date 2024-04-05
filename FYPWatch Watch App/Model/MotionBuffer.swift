//
//  MotionBuffer.swift
//  FYP
//
//  Created by Lee Chilvers on 01/04/2024.
//

import Foundation

// a thread safe buffer
actor MotionBuffer {
    
    private let size: Int
    private(set) var elements: [MotionData] = []
    
    init(size: Int) {
        self.size = size
    }
    
    func getSnapshot(size: Int, with stroke: UserStroke) -> [MotionData] {
        guard !elements.isEmpty, size > 0 else { return [] }
        // search for motion data end
        var i = 0
        for index in stride(from: elements.count-1, through: 0, by: -1) {
            if elements[index].timestamp > stroke.timestamp { continue }
            i = index; break
        }
        // get snapshot of size
        let j = max(0, (i + 1) - size)
        var snapshot = Array(elements[j...i])
        // pad if smaller than size
        if snapshot.count < size,
           let first = snapshot.first {
            snapshot = Array(
                repeating: first,
                count: size - snapshot.count
            ) + snapshot
        }
        
        // cut off used data
        elements = Array(elements[i...])
        
        return snapshot
    }
    
    func add(_ element: MotionData) {
        elements.append(element)
        if elements.count > size {
            elements.removeFirst()
        }
    }
    
    func removeAll() {
        elements = []
    }
}
