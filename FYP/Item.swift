//
//  Item.swift
//  FYP
//
//  Created by Lee Chilvers on 06/01/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
