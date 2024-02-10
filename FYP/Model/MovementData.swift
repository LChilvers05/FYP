//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

struct MovementData {
    var acceleration: CMAcceleration?
    var rotation: CMRotationRate?
    var time: Double
    var id: Int = 0
    
    static var count: Int = 0
    
    init(time: Double) {
        self.time = time
        self.id = MovementData.count
        MovementData.count += 1
    }
}
