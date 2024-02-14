//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

struct MovementData {
    var id: Int = 0
    var acceleration: CMAcceleration?
    var rotation: CMRotationRate?
    var timestamp: TimeInterval
    
    static var count: Int = 0
    
    init(_ timestamp: TimeInterval) {
        self.timestamp = timestamp
        self.id = MovementData.count
        MovementData.count += 1
    }
    
    func isInitialised() -> Bool {
        return (
            id != 0 &&
            acceleration != nil &&
            rotation != nil
        )
    }
}
