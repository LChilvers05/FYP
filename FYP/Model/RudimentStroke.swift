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
    func getRhythmResult(for beat: Double) -> ComparisonResult {
        if (beat >= positionInBeats && beat <= success) ||
            (beat >= early && beat <= nextPositionInBeats) {
            return .success
        } else if beat >= success && beat <= late {
            return .late
        } else if beat >= late && beat <= early {
            return .early
        } else {
            return .missed
        }
    }
}
