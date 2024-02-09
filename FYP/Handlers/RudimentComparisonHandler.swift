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
    
    // Improvement: same sequencer object as metronome and add track
    private var sequencer = AppleSequencer() // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    private let sequencerLength: Double // of sequencer
    
    private var results: [Feedback?] = []
    private var strokes: [RudimentStroke] = []
    private var focus = -1
    
    private var isPlaying: Bool {
        get { return sequencer.isPlaying }
    }
    
    var positionInBeats: Double {
        get {
            sequencer.currentPosition.beats
                .truncatingRemainder(dividingBy: sequencerLength)
        }
    }
    
    init(_ rudiment: Rudiment,
         _ tempo: Int,
         length: Duration = Duration(beats: 4.0)) {
        sequencerLength = length.beats
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        setupSequencer(rudiment, tempo, length)
        createStrokes(from: rudiment, and: midiFile)
    }
    
    func beginComparison() {
        guard !isPlaying else { return }
        sequencer.play()
    }
    
    func stopComparison() {
        guard isPlaying else { return }
        sequencer.rewind()
        sequencer.stop()
    }
    
    //TODO: issue is when I strike on beat one,
    // get feedback on beat 2 and
    // beat 1 is marked as .missed
    
    // stroke input from user
    func compare(userStroke: UserStroke) {
        guard focus >= 0 else { return }
        let stroke = strokes[focus]
//TODO:        let nextStroke = strokes[(focus+1) % strokes.count]
        // compare rhythm
        let rhythmResult = stroke.checkRhythm(for: userStroke.positionInBeats)
        
        let next = min(focus+1, results.count-1)
        switch rhythmResult { // after this stroke
        case .success, .late:
            // mark feedback
            results[focus] = rhythmResult
//TODO:            (stroke.sticking == userStroke.sticking) ?
//            rhythmResult : .sticking
            
        case .early, .nextSuccess: // before next stroke
            if results[focus] == nil { results[focus] = .late }
            results[next] = (rhythmResult == .nextSuccess) ? .success : rhythmResult
//TODO:            (nextStroke.sticking == userStroke.sticking) ?
//            rhythmResult : .sticking
            
        default:
            results[focus] = rhythmResult
        }
    }
    
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard let type = MIDIStatus(byte: status)?.type,
              type == .noteOn else { return } // note on
        // check for missed strokes
        if focus >= 0 && results[focus] == nil {
            results[focus] = .missed
        }
        // next event
        focus += 1
        
        // reset feedback results
        if focus == strokes.count {
            focus = 0
            repository.savePractice(results)
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
    
    private func setupSequencer(_ rudiment: Rudiment, 
                                _ tempo: Int,
                                _ length: Duration) {
        sequencer.loadMIDIFile(rudiment.midi)
        sequencer.setTempo(Double(tempo))
        sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
        sequencer.setLength(length)
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
