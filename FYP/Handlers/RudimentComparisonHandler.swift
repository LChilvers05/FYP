//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit

// compare players input to rudiment data and return result
final class RudimentComparisonHandler {
    
    private let repository = Repository()
    
    private var sequencer = AppleSequencer() // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    
    private var results: [Feedback?] = []
    private var strokes: [RudimentStroke] = []
    private var focus = -1
    
    init(_ rudiment: Rudiment, _ tempo: Int) {
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        
        setupSequencer(rudiment, tempo)
        createStrokes(from: rudiment, and: midiFile)
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
        guard focus >= 0 else { return }
        let stroke = strokes[focus]
        let nextStroke = strokes[(focus+1) % strokes.count]
        // compare rhythm
        let rhythmResult = stroke.checkRhythm(for: userStroke.positionInBeats)
        
        var i = focus // for marking feedback
        var feedback: Feedback?
        switch rhythmResult { // after this stroke
        case .success, .late:
            feedback = (stroke.sticking == userStroke.sticking) ?
            rhythmResult : .sticking
        case .early, .nextSuccess: // before next stroke
            feedback = (nextStroke.sticking == userStroke.sticking) ?
            rhythmResult : .sticking
            i += 1 // mark next
        default:
            feedback = rhythmResult
        }
        // mark result
        results[i] = feedback
    }
    
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard status == 144 else { return } // note on //TODO: sequencer will have double!
        // check for missed strokes
        if focus >= 0 && results[focus] == nil {
            results[focus] = .missed
        }
        print(focus)
        // next event
        focus += 1
        
        // reset feedback results
        if focus == strokes.count {
            focus = 0
            print(results)
            results = Array(repeating: nil, count: strokes.count)
        }
    }
    
    // initialise list of rudiment strokes from the rudiment data and MIDI events
    private func createStrokes(from rudiment: Rudiment, and midiFile: MIDIFile?) {
        // filter to note on events
        guard let events = midiFile?.getEventsOf(type: .noteOn) else { return }
        
        let stickingPattern = rudiment.getStickingPattern()
        if stickingPattern.count != events.count {
            print("MIDI file is different length to rudiment data")
            print("events: \(events.count), expected: \(stickingPattern.count)")
            return
        }
        
        strokes.removeAll()
        results.removeAll()
        
        for (i, event) in events.enumerated() {
            let nextEvent = events[(i + 1) % events.count] //wrap to first
            guard let pos = event.positionInBeats,
                  var nextPos = nextEvent.positionInBeats else { break }
            if nextPos < pos { nextPos = sequencer.length.beats }
            
            let sticking = stickingPattern[i]
            
            // rhythm check windows
            let n = 0.3
            let late = (pos + nextPos)/2.0
            let success = pos + n*(late - pos)
            let early = late + (1.0-n)*(nextPos - late)
            
            strokes.append(RudimentStroke(
                sticking: sticking,
                positionInBeats: pos,
                success: success,
                late: late,
                early: early,
                nextPositionInBeats: nextPos
            ))
        }
        results = Array(repeating: nil, count: strokes.count)
    }
    
    private func setupSequencer(_ rudiment: Rudiment, _ tempo: Int) {
        sequencer.loadMIDIFile(rudiment.midi)
        sequencer.setTempo(Double(tempo))
        sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
        sequencer.enableLooping()
        midiCallback.callback = playStroke
    }
    
    deinit {
        stopComparison()
    }
}

enum Feedback {
    case success,
         late,
         early,
         nextSuccess,
         missed,
         sticking,
         volume,
         error
}
