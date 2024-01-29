//
//  PracticeView.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import SwiftUI

struct PracticeView: View {
    
    private var rudiment: Rudiment?
    private var viewModel: PracticeViewModel?
    
    init(rudiment: Rudiment) {
        self.rudiment = rudiment
        self.viewModel = PracticeViewModel(rudiment)
    }
    
    var body: some View {
        if let rudiment {
            VStack {
                Text("Rudiment #\(rudiment.id): \(rudiment.name)")
                Text("MIDI: \(rudiment.midi)")
                Text("Image: \(rudiment.image)")
                
                Button("Listen") {
                    self.viewModel?.beginPractice()
                }
            }
            .navigationTitle(rudiment.name)
        }
    }
}
