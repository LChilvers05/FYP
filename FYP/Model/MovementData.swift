//
//  MovementData.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreMotion

class MovementData: Codable {
    var id: Int = 0
    let timestamp: TimeInterval
    let accX, accY, accZ: Double
    let rotX, rotY, rotZ: Double
    
    private static var count: Int = 0
    
    init(acceleration: CMAcceleration,
         rotation: CMRotationRate,
         timestamp: TimeInterval) {
        
        self.timestamp = timestamp
        
        self.accX = acceleration.x
        self.accY = acceleration.y
        self.accZ = acceleration.z
        
        self.rotX = rotation.x
        self.rotY = rotation.y
        self.rotZ = rotation.z
        
        
        self.id = MovementData.count
        MovementData.count += 1
    }
    
    private enum CodingKeys: String, CodingKey {
        case id,
             timestamp,
             accX,
             accY,
             accZ,
             rotX,
             rotY,
             rotZ
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        timestamp = try values.decode(TimeInterval.self, forKey: .timestamp)
        
        accX = try values.decode(Double.self, forKey: .accX)
        accY = try values.decode(Double.self, forKey: .accY)
        accZ = try values.decode(Double.self, forKey: .accZ)
        
        rotX = try values.decode(Double.self, forKey: .rotX)
        rotY = try values.decode(Double.self, forKey: .rotY)
        rotZ = try values.decode(Double.self, forKey: .rotZ)
    }
}
