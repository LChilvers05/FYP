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
            Spacer()
            MetronomeView(metronome: viewModel.metronome)
            ControlsView(
                playAction: viewModel.beginPractice,
                stopAction: viewModel.endPractice
            )
            
        }
        .navigationTitle(rudiment.name)
    }
}

struct MetronomeView: View {
    
    @ObservedObject var metronome: Metronome
    
    var body: some View {
        Text("\(metronome.beat)")
            .font(.system(size: 30.0))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
    }
}

struct ControlsView: View {
    
    let playAction: (() -> Void)
    let stopAction: (() -> Void)
    
    var body: some View {
        HStack {
            Spacer()
            circularActionButton(
                action: self.playAction,
                image: "play.fill"
            )
            Spacer()
            circularActionButton(
                action: self.stopAction,
                image: "stop.fill"
            )
            Spacer()
        }
    }
    
    private func circularActionButton(action: @escaping () -> Void,
                                      image: String) -> some View {
        return Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 40.0))
                .foregroundColor(.primary)
                .padding(20.0)
                .background(.background)
                .clipShape(Circle())
                .overlay(Circle().stroke(.secondary))
        }
        
    }
}

#Preview {
    PracticeView(rudiment: Rudiment(
        id: 1,
        name: "Single Stroke Roll",
        midi: "single_stroke_roll",
        image: "single_stroke_roll.png",
        pattern: "RL",
        patternRepeats: 8)
    )
}
