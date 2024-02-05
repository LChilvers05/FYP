//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit

// compare players input to rudiment data and return result
final class RudimentComparisonHandler {
    
    private let repository = Repository()
    
    private var sequencer: AppleSequencer // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    
    private var strokes: [Stroke] = [] // rudiment strokes
    private var focus = 0 // changed as sequencer plays (a pointer)
    private var isNoteOn = false
    
    init(_ rudiment: Rudiment) {
        sequencer = AppleSequencer(filename: rudiment.midi)
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        let events = midiFile?.tracks.first?.events ?? []
        
        createStrokes(from: rudiment, and: events)
    }
    
    func beginComparison() {
        sequencer.play()
    }
    
    func stopComparison() {
        sequencer.rewind()
        sequencer.stop()
    }
    
    // stroke input from user
    func compare(userStroke: Stroke) -> [ComparisonResult] {
        let stroke = strokes[focus] //?
        
        
        //TODO:
        // need a pointer to current stroke being processed:
        // perhaps use Apple sequencer to play midi track in background
        // then mark each midi event with a ComparisonResult based on stroke input
        
        return [.success]
    }
    
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        if status == 144 { // note on
            isNoteOn = true
            
        } else if status == 128 { // note off
            isNoteOn = false
            focus = (focus + 1) % strokes.count
        }
    }
    
    // initialise an array of strokes from the rudiment data and MIDI events
    private func createStrokes(from rudiment: Rudiment, and events: [MIDIEvent]) {
        strokes.removeAll()
        let stickingPattern = rudiment.getStickingPattern()
        
        if stickingPattern.count != events.count {
            print("MIDI file is different length to rudiment data")
            print("events: \(events.count), expected: \(stickingPattern.count)")
            return
        }
        
        for (i, event) in events.enumerated() {
            guard let positionInBeats = event.positionInBeats else { continue }
            let sticking = stickingPattern[i]
            
            strokes.append(Stroke(
                positionInBeats: positionInBeats,
                sticking: sticking
            ))
        }
    }
    
    private func setupSequencer() {
        sequencer.tracks.first?.setMIDIOutput(midiCallback.midiIn)
        midiCallback.callback = playStroke
        sequencer.enableLooping()
    }
    
    deinit {
        stopComparison()
    }
}

enum ComparisonResult {
    case success,
         rhythmError,
         stickError,
         dynamicError,
         error
}
