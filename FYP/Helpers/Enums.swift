//
//  Enums.swift
//  FYP
//
//  Created by Lee Chilvers on 13/03/2024.
//

import Foundation

enum Sticking: Codable {
    case left, right
}

enum Annotation: Codable {
    case early,
         success,
         late,
         nextEarly,
         nextSuccess,
         missed,
         sticking,
         error
}
