//
//  AmplitudeData.swift
//  FYP
//
//  Created by Lee Chilvers on 30/01/2024.
//

import Foundation

struct AmplitudeData: Codable {
    var id: Int = 0
    var amplitude: Float = 0.0
    
    static var count: Int = 0
    
    init(amplitude: Float) {
        self.amplitude = amplitude
        self.id = AmplitudeData.count
        AmplitudeData.count += 1
    }
}
