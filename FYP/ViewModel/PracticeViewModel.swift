//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AudioKit
import Combine

final class PracticeViewModel: ObservableObject {
    
    @Published var metronome: Metronome
    
    private lazy var onsetDetector = OnsetDetectionHandler()
    private let rudimentComparison: RudimentComparisonHandler
    private let tempo = 50
        
    init(_ rudiment: Rudiment) {
        metronome = Metronome(bpm: tempo)
        rudimentComparison = RudimentComparisonHandler(rudiment, tempo)
        metronome.didCountIn = self.didCountIn
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func beginPractice() {
        onsetDetector.beginDetecting()
        metronome.start()
    }
    
    func endPractice() {
        onsetDetector.stopDetecting()
        metronome.stop()
        rudimentComparison.stopComparison()
    }
    
    private func didCountIn() {
        rudimentComparison.beginComparison()
    }
    
    private func didDetectOnset(_ onsetTime: AmplitudeData?) {
        guard !metronome.isCountingIn else { return } // ignore count in
    }
}
