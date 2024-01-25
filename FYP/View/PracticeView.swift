//
//  PracticeView.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import SwiftUI

struct PracticeView: View {
    var rudiment: Rudiment?
    
    var body: some View {
        if let rudiment {
            VStack {
                Text("Rudiment #\(rudiment.id): \(rudiment.name)")
                Text("MIDI: \(rudiment.midi)")
                Text("Image: \(rudiment.image)")
                
                Button("Listen") {
                    AudioService.shared.startListening()
                }
            }
            .navigationTitle(rudiment.name)
        }
    }
}
