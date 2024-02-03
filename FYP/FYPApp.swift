//
//  FYPApp.swift
//  FYP
//
//  Created by Lee Chilvers on 06/01/2024.
//

import AudioKit
import SwiftUI

@main
struct FYPApp: App {
    
    init() {
        try? Settings.session.setCategory(.playAndRecord, options: .allowBluetoothA2DP)
    }

    var body: some Scene {
        WindowGroup {
            MenuView()
        }
    }
}
