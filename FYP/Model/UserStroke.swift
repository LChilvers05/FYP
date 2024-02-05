//
//  Stroke.swift
//  FYP
//
//  Created by Lee Chilvers on 05/02/2024.
//

import Foundation

struct UserStroke {
    let positionInBeats: Double
    let sticking: Sticking
}

enum Sticking {
    case left, right
}