//
//  Stroke.swift
//  FYP
//
//  Created by Lee Chilvers on 05/02/2024.
//

import Foundation

struct UserStroke: Codable {
    var id: Int = 0
    var feedback: Annotation?
    var sticking: Sticking?
    let positionInBeats: Double
    let amplitude: AmplitudeData
    let timestamp: TimeInterval
    
    static var count: Int = 0
    
    init(positionInBeats: Double,
         amplitude: AmplitudeData,
         timestamp: TimeInterval) {
        self.positionInBeats = positionInBeats
        self.amplitude = amplitude
        self.timestamp = timestamp
        self.id = UserStroke.count
        UserStroke.count += 1
    }
}
