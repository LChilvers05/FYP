//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit

// compare players input to rudiment data and return result
final class RudimentPlayer {
    
    private let repository = Repository()
    
    let sequencer = AppleSequencer() // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    private let sequencerLength: Double // of sequencer
    
    // nx3 for results buffer
    private var results: [[Feedback?]] = []
    private var strokes: [RudimentStroke] = []
    private var focus = -1
    
    private var isPlaying: Bool {
        get { return sequencer.isPlaying }
    }
    
    init(_ rudiment: Rudiment,
         _ tempo: Int,
         length: Duration = Duration(beats: 4.0)) {
        sequencerLength = length.beats
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        setupSequencer(rudiment, tempo, length)
        createStrokes(from: rudiment, and: midiFile)
    }
    
    // stroke input from user
    func score(_ userStroke: UserStroke) {
        guard isPlaying else { return }
        Task {
            await compare(userStroke, curr: focus, next: focus+1)
        }
    }
    
    // search feedback and update sticking
    func updateSticking(_ userStroke: UserStroke) {
        guard isPlaying else { return }
    }
    
    // score feedback
    @MainActor
    private func compare(_ userStroke: UserStroke, curr: Int, next: Int) {
        // results list pointer
        var i = 1
        if curr < 0 { i = 0 }
        if next >= strokes.count { i = 2 }
        
        // stroke pointers
        let curr = (curr + strokes.count) % strokes.count // wrap
        let next = (next + strokes.count) % strokes.count
        
        let stroke = strokes[curr]
        // compare rhythm
        let rhythm = stroke.checkRhythm(for: userStroke.positionInBeats)
        
        switch rhythm {
        case .early:
            // feedback for previous stroke
            compare(userStroke, curr: curr-1, next: curr)
        case .success, .late:
            // feedback for current stroke
            results[i][curr] = rhythm
        case .nextEarly, .nextSuccess:
            // feedback for next stroke
            results[i][next] = (rhythm == .nextEarly) ? .early : .success
        default:
            results[i][curr] = rhythm
        }
    }
    
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard let type = MIDIStatus(byte: status)?.type,
              type == .noteOn else { return } // note on
        Task {
            await MainActor.run {
                // check for missed strokes
                if focus >= 0 && results[1][focus] == nil {
                    results[1][focus] = .missed
                }
                // next event
                focus += 1
                
                // reset feedback results
                if focus == strokes.count {
                    focus = 0
                    // save prev feedback
                    repository.savePractice(results[0])
                    // shift along results buffer
                    results[0] = results[1]
                    results[1] = results[2]
                    results[2] = Array(repeating: nil, count: strokes.count)
                }
            }
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
            let late = 0.5*(pos + nextPos)
            let success = 0.5*(pos + late)
            let early = 0.5*(late + nextPos)
            
            strokes.append(RudimentStroke(
                sticking: sticking,
                positionInBeats: pos,
                success: success,
                late: late,
                early: early,
                nextPositionInBeats: nextPos
            ))
        }
        
        results = Array(
            repeating: Array(repeating: nil, count: strokes.count),
            count: 3
        )
    }
    
    private func setupSequencer(_ rudiment: Rudiment, 
                                _ tempo: Int,
                                _ length: Duration) {
        // plays at metronome start
        sequencer.loadMIDIFile(rudiment.midi)
        sequencer.setTempo(Double(tempo))
        sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
        sequencer.setLength(length)
        midiCallback.callback = playStroke
    }
}

enum Feedback {
    case early,
         success,
         late,
         nextEarly,
         nextSuccess,
         missed,
         sticking,
         volume,
         error
}
