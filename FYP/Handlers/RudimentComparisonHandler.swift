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
    
    private var feedback: [ComparisonResult?] = []
    private var strokes: [RudimentStroke] = []
    private var focus = -1
    
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
    func compare(userStroke: UserStroke) {
        let stroke = strokes[focus]
        let nextStroke = strokes[(focus+1) % strokes.count]
        // compare rhythm
        let rhythmResult = stroke.checkRhythm(for: userStroke.positionInBeats)
        
        var i = focus // for marking feedback
        var result: ComparisonResult = .error
        switch rhythmResult { // after this stroke
        case .success, .late:
            result = (stroke.sticking == userStroke.sticking) ?
            rhythmResult : .sticking
        case .early, .nextSuccess: // before next stroke
            result = (nextStroke.sticking == userStroke.sticking) ?
            rhythmResult : .sticking
            i += 1 // mark next
        default:
            break
        }
        // mark result
        feedback[i] = result
    }
    
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard status == 144 else { return } // note on
        // check for missed strokes
        if focus >= 0 && feedback[focus] == nil { feedback[focus] = .missed }
        focus = (focus + 1) % strokes.count // move to next midi event
    }
    
    // initialise list of rudiment strokes from the rudiment data and MIDI events
    private func createStrokes(from rudiment: Rudiment, and events: [MIDIEvent]) {
        strokes.removeAll()
        feedback.removeAll()
        let stickingPattern = rudiment.getStickingPattern()
        if stickingPattern.count != events.count {
            print("MIDI file is different length to rudiment data")
            print("events: \(events.count), expected: \(stickingPattern.count)")
            return
        }
        
        for (i, event) in events.enumerated() {
            let nextEvent = events[(i + 1) % events.count] //wrap to first
            guard let positionInBeats = event.positionInBeats,
                  let nextPositionInBeats = nextEvent.positionInBeats else { break }
            let sticking = stickingPattern[i]
            
            // rhythm check windows
            let n = 0.3
            let late = (positionInBeats + nextPositionInBeats)/2.0
            let success = positionInBeats + n*(late - positionInBeats)
            let early = late + (1.0-n)*(nextPositionInBeats - late)
            
            strokes.append(RudimentStroke(
                sticking: sticking,
                positionInBeats: positionInBeats,
                success: success,
                late: late,
                early: early,
                nextPositionInBeats: nextPositionInBeats
            ))
        }
        feedback = Array(repeating: nil, count: strokes.count)
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
         late,
         early,
         nextSuccess,
         missed,
         sticking,
         volume,
         error
}
