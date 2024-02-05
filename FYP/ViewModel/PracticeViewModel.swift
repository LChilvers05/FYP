//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AudioKit
import Combine

final class PracticeViewModel: ObservableObject {
    
    @Published var metronome = Metronome(tempo: 100)
    
    private lazy var onsetDetector = OnsetDetectionHandler()
    private let rudimentComparison: RudimentComparisonHandler
        
    init(_ rudiment: Rudiment) {
        rudimentComparison = RudimentComparisonHandler(rudiment)
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func beginPractice() {
        onsetDetector.beginDetecting()
        metronome.start()
    }
    
    func endPractice() {
        onsetDetector.stopDetecting()
        metronome.stop()
    }
    
    private func didDetectOnset(_ onsetTime: AmplitudeData?) {
        print(metronome.isCountingIn)
        guard !metronome.isCountingIn else { return } // ignore count in
    }
}
