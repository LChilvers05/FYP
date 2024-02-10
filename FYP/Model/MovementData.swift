//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

struct MovementData {
    let acceleration: CMAcceleration
    let rotation: CMRotationRate
    var time: Double
    var id: Int = 0
    
    static var count: Int = 0
    
    init(acceleration: CMAcceleration,
         rotation: CMRotationRate,
         time: Double) {
        self.acceleration = acceleration
        self.rotation = rotation
        self.time = time
        self.id = MovementData.count
        MovementData.count += 1
    }
}
