//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit

final class MIDIComparisonHandler {
    
    private let midiFile: MIDIFile?
    private let repository = Repository()
    
    init(_ midi: String) {
        midiFile = repository.getRudimentMIDI(midi)
    }
    
    func makeMIDIEvent(onsetTime: AVAudioTime) {
        print(onsetTime.hostTime)
    }
}
