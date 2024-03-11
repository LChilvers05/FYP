//
//  RudimentNode.swift
//  FYP
//
//  Created by Lee Chilvers on 05/02/2024.
//

import Foundation

struct RudimentStroke {
    let sticking: Sticking
    let positionInBeats: Double
    let success: Double
    let late: Double
    let early: Double
    let nextPositionInBeats: Double
}

extension RudimentStroke {
    func checkRhythm(for beat: Double) -> Annotation {
        if beat >= positionInBeats && beat <= success {
            return .success
        } else if beat >= success && beat <= late {
            return .late
        } else if beat >= late && beat <= early {
            return .nextEarly
        } else if beat >= early && beat <= nextPositionInBeats {
            return .nextSuccess
        } else {
            return .early
        }
    }
}
