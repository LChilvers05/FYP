//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AVFoundation

final class PracticeViewModel {
    
    //TODO: create a metronome with AppleSequencer
    // it resets MetronomeTimer.value at end of bar
    // use it to count in -> then do onset detection
    
    private let metronome = Metronome()
    private let timer = MetronomeTimer(bpm: 90)
    private let onsetDetector = OnsetDetectionHandler()
    private let MIDIComparison: MIDIComparisonHandler
    
    init(_ rudiment: Rudiment) {
        MIDIComparison = MIDIComparisonHandler(rudiment.midi)
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func beginPractice() {
        //TODO: begin count in
//        timer.start()
        
        
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
