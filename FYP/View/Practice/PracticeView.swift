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
            
//            Button {
//                viewModel.tester(feedback: [
//                    [.success, .success, .success, .success, .early, .late, .late, .late, .early, .success, .success, .success, .sticking, .success, .success, .missed],
//                    [.success, .success, .success, .success, .early, .late, .missed, .late, .early, .success, nil, nil, nil, nil, nil, nil],
//                    []
//                ])
//            } label: {
//                Text("Show results")
//            }
            
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
