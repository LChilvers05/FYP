//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AVFoundation

final class PracticeViewModel {
    
    private lazy var metronome = Metronome(tempo: 100)
    private lazy var onsetDetector = OnsetDetectionHandler()
    private let midiComparison: MIDIComparisonHandler
    
    init(_ rudiment: Rudiment) {
        midiComparison = MIDIComparisonHandler(rudiment.midi)
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func beginPractice() {
        metronome.start()
//        onsetDetector.beginDetecting()
    }
    
    func endPractice() {
        metronome.stop()
        onsetDetector.stopDetecting()
    }
    
    private func didDetectOnset(_ onsetTime: AVAudioTime) {
        //time of stroke
        midiComparison.makeMIDIEvent(onsetTime: onsetTime)
    }
}
