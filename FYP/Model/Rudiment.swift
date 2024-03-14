//
//  Rudiment.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import AudioKit
import Foundation

struct Rudiment: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let midi: String
    let view: String
    let pattern: String
    let patternRepeats: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, midi, view, pattern
        case patternRepeats = "pattern_repeats"
    }
}

extension Rudiment {
    func getStickingPattern() -> [Sticking] {
        var sticking: [Sticking] = []
        for s in pattern {
            switch s {
            case "R":
                sticking.append(.right)
            case "L":
                sticking.append(.left)
            default:
                continue
            }
        }
        
        return Array(
            repeating: sticking,
            count: patternRepeats
        ).flatMap { $0 }
    }
    
    func getStrokeCount() -> Int {
        pattern.count * patternRepeats
    }
}
