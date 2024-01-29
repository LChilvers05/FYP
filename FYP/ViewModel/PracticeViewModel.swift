//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AVFoundation

final class PracticeViewModel {
    
    private let onsetDetector = OnsetDetectionHandler()
    private let MIDIComparison: MIDIComparisonHandler
    
    init(_ rudiment: Rudiment) {
        MIDIComparison = MIDIComparisonHandler(rudiment.midi)
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func beginPractice() {
        onsetDetector.beginDetecting()
    }
    
    func endPractice() {
        onsetDetector.stopDetecting()
    }
    
    private func didDetectOnset(_ onsetTime: AVAudioTime) {
        //time of stroke
        MIDIComparison.makeMIDIEvent(onsetTime: onsetTime)
    }
}
