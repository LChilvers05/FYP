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
    @State private var isShowingKey = false
    
    init(rudiment: Rudiment) {
        self.rudiment = rudiment
        self._viewModel = StateObject(wrappedValue: PracticeViewModel(rudiment))
    }
    
    var body: some View {
        VStack {
            Spacer()
            if isShowingKey { FeedbackKeyView() }
            // prev attempt
            RudimentRepresentable(
                rudimentViewRequest: viewModel.rudimentViewRequest,
                isLoading: $isLoading,
                javaScript: $viewModel.prevAttemptUpdates
            )
            .padding(EdgeInsets(top: .zero, leading: 40.0, bottom: .zero, trailing: 40.0))
            .frame(height: 120)
            .opacity(0.5)
            .onAppear { isLoading = false }
            
            // rudiment view
            RudimentRepresentable(
                rudimentViewRequest: viewModel.rudimentViewRequest,
                isLoading: $isLoading,
                javaScript: $viewModel.attemptUpdates
            )
            .frame(height: 120)
            .onAppear { isLoading = false }
            
            Spacer()
            
            // metronome
            Text("\(viewModel.metronome.beat)")
                .font(.system(size: 50.0))
                .padding()
            
            // start/stop
            Button(action: viewModel.startStopTapped) {
                Image(systemName: startStopSymbol())
                    .animation(nil, value: UUID())
                    .blueCircularStyle()
            }
            
            // tempo
            Stepper(
                value: $viewModel.tempo,
                in: 50...200,
                step: 10,
                label: { Text("Tempo: \(viewModel.tempo)") }
            )
            .padding(EdgeInsets(top: 20.0, leading: 80.0, bottom: 20.0, trailing: 80.0))
            .onChange(of: viewModel.tempo) { _, newValue in
                viewModel.update(newValue)
            }
        }
        .navigationTitle(rudiment.name)
        .toolbar {
            Button {
                isShowingKey.toggle()
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
    }
    
    private func startStopSymbol() -> String {
        viewModel.isPlaying ?
        "stop.fill" : "play.fill"
    }
}


#Preview {
    NavigationStack {
        PracticeView(rudiment: Rudiment(
            id: 1,
            name: "Single Stroke Roll",
            midi: "single_stroke_roll",
            view: "single_stroke_roll",
            pattern: "RL",
            patternRepeats: 8)
        )
    }
}
