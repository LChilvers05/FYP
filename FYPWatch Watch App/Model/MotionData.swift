//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

class MotionData: Codable {
    var id: Int = 0
    let timestamp: TimeInterval
    let accelerationX: Double
    let accelerationY: Double
    let accelerationZ: Double
    let rotationX: Double
    let rotationY: Double
    let rotationZ: Double
    
    private static var count: Int = 0
    
    init(timestamp: TimeInterval,
         acceleration: CMAcceleration,
         rotation: CMRotationRate) {
        
        self.timestamp = timestamp
        self.accelerationX = acceleration.x
        self.accelerationY = acceleration.y
        self.accelerationZ = acceleration.z
        self.rotationX = rotation.x
        self.rotationY = rotation.y
        self.rotationZ = rotation.z
        
        self.id = MotionData.count
        MotionData.count += 1
    }
}
