//
//  AmplitudeData.swift
//  FYP
//
//  Created by Lee Chilvers on 30/01/2024.
//

import AudioKit

struct AmplitudeData {
    var id: Int = 0
    var amplitude: AUValue = 0.0
    
    static var count: Int = 0
    
    init(amplitude: AUValue) {
        self.amplitude = amplitude
        self.id = AmplitudeData.count
        AmplitudeData.count += 1
    }
}
