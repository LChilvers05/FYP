//
//  PracticeView.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import SwiftUI

struct PracticeView: View {
    
    private let rudiment: Rudiment
    @StateObject private var viewModel: PracticeViewModel
    
    init(rudiment: Rudiment) {
        self.rudiment = rudiment
        self._viewModel = StateObject(wrappedValue: PracticeViewModel(rudiment))
    }
    
    var body: some View {
        VStack {
            MetronomeView(metronome: viewModel.metronome)
            Text("Rudiment #\(rudiment.id): \(rudiment.name)")
            Text("MIDI: \(rudiment.midi)")
            Text("Image: \(rudiment.image)")
            
            Button("Listen") {
                self.viewModel.beginPractice()
            }
        }
        .navigationTitle(rudiment.name)
    }
}

struct MetronomeView: View {
    
    @ObservedObject var metronome: Metronome
    
    var body: some View {
        Text("\(metronome.beat)")
    }
}
