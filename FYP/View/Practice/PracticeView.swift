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
    @State private var isLoading = true
    @State private var javaScript = ""
    
    init(rudiment: Rudiment) {
        self.rudiment = rudiment
        self._viewModel = StateObject(wrappedValue: PracticeViewModel(rudiment))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // rudiment view
            RudimentRepresentable(
                rudimentViewRequest: viewModel.rudimentViewRequest,
                isLoading: $isLoading,
                javaScript: $javaScript
            )
            .onAppear { isLoading = false }
            
            Spacer()
            
            // tester
            Button {
                javaScript = "document.getElementById('name').innerText = \"John Appleseed\";"
            } label: {
                Text("Change name")
            }

            
            // metronome and playback controls
            MetronomeView(metronome: viewModel.metronome)
            ControlsView(
                playAction: viewModel.startPractice,
                stopAction: viewModel.endPractice
            )
            
        }
        .navigationTitle(rudiment.name)
    }
}

#Preview {
    PracticeView(rudiment: Rudiment(
        id: 1,
        name: "Single Stroke Roll",
        midi: "single_stroke_roll",
        view: "single_stroke_roll",
        pattern: "RL",
        patternRepeats: 8)
    )
}