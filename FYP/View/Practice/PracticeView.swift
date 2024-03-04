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
    
    init(rudiment: Rudiment) {
        self.rudiment = rudiment
        self._viewModel = StateObject(wrappedValue: PracticeViewModel(rudiment))
    }
    
    var body: some View {
        VStack {
            
            // prev attempt
            RudimentRepresentable(
                rudimentViewRequest: viewModel.rudimentViewRequest,
                isLoading: $isLoading,
                javaScript: $viewModel.prevAttemptUpdates
            )
            .padding(40)
            .frame(height: 240)
            .opacity(0.5)
            .onAppear { isLoading = false }
            
            // rudiment view
            RudimentRepresentable(
                rudimentViewRequest: viewModel.rudimentViewRequest,
                isLoading: $isLoading,
                javaScript: $viewModel.attemptUpdates
            )
            .frame(height: 200)
            .onAppear { isLoading = false }
            
            Spacer()
            
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
