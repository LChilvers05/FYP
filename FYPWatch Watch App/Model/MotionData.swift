//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

class MotionData {
    var id: Int = 0
    let acceleration: CMAcceleration
    let rotation: CMRotationRate
    let timestamp: TimeInterval
    
    private static var count: Int = 0
    
    init(acceleration: CMAcceleration,
         rotation: CMRotationRate,
         timestamp: TimeInterval) {
        
        self.acceleration = acceleration
        self.rotation = rotation
        self.timestamp = timestamp
        
        self.id = MotionData.count
        MotionData.count += 1
    }
}
