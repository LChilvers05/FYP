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
    let image: String
}
