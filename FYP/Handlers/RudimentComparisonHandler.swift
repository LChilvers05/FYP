//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit

final class RudimentComparisonHandler {
    
    private let repository = Repository()
    private var strokes: [Stroke] = []
    
    init(_ rudiment: Rudiment) {
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        let events = midiFile?.tracks.first?.events ?? []
        createStrokes(from: rudiment, and: events)
    }
    
    func compare(stroke: Stroke) -> [ComparisonResult] {
        //TODO: 
        // need a pointer to current stroke being processed
        // how to do rhythm when user is late
        
        return [.success]
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
}

enum ComparisonResult {
    case success,
         rhythmError,
         stickError,
         dynamicError,
         error
}
