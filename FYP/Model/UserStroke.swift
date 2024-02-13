//
//  Stroke.swift
//  FYP
//
//  Created by Lee Chilvers on 05/02/2024.
//

import Foundation

struct UserStroke { //TODO: use User stroke to fill feedback DS
    var id: Int = 0
    var feedback: Feedback?
    var sticking: Sticking?
    let positionInBeats: Double
    let amplitude: AmplitudeData
    let time: Double
    
    static var count: Int = 0
    
    init(positionInBeats: Double,
         amplitude: AmplitudeData,
         time: Double) {
        self.positionInBeats = positionInBeats
        self.amplitude = amplitude
        self.time = time
        self.id = UserStroke.count
        UserStroke.count += 1
    }
}

enum Sticking {
    case left, right
}
