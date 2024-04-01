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
    private var elements: [MotionData] = []
    
    init(size: Int) {
        self.size = size
    }
    
    func getSnapshot(size: Int, with stroke: UserStroke) -> [MotionData] {
        let i = elements.firstIndex(
            where: { $0.timestamp >= stroke.timestamp }
        ) ?? elements.count-1
        guard size > 0, i > 0 else { return [] }
        // get snapshot of size
        let j = max(0, (i + 1) - size)
        let snapshot = Array(elements[j...i])
        // trim to unused data
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
