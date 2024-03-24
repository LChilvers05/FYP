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
    
    private(set) var feedback: Feedback?
    
    let sequencer = AppleSequencer() // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    private let sequencerLength: Double // of sequencer
    
    var didAnnotateFeedback: (([Annotation?]) -> Void)?
    
    private var isPlaying: Bool {
        get { return sequencer.isPlaying }
    }
    
    init(_ rudiment: Rudiment,
         _ midiFile: MIDIFile,
         length: Duration = Duration(beats: 4.0)) {
        sequencerLength = length.beats
        setupSequencer(rudiment, length)
        
        let strokes = createStrokes(from: rudiment, and: midiFile)
        
        Task {
            feedback = Feedback(strokes)
            await feedback?.clear()
        }
    }
    
    // check user rhythm
    func scoreRhythm(for userStroke: UserStroke) {
        guard isPlaying else { return }
        Task {
            await feedback?.scoreRhythm(
                for: userStroke,
                i: 1, curr: feedback?.ptr ?? 0
            )
        }
    }
    
    // check user sticking faults
    func checkSticking(for userStroke: UserStroke) {
        guard isPlaying else { return }
        Task { await feedback?.checkSticking(for: userStroke) }
    }
    
    func rewind() {
        Task { await feedback?.clear() }
    }
    
    // sequencer plays MIDI note
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard let type = MIDIStatus(byte: status)?.type,
              type == .noteOn else { return } // note on
        Task {
            if let feedback,
               await feedback.ptr+1 == feedback.strokes.count {
                let annotations = await feedback.annotations[0]
                if annotations[0] != nil {
                    // a complete attempt to log
                    didAnnotateFeedback?(annotations)
                }
            }
            await feedback?.shift()
        }
    }
    
    // initialise list of rudiment strokes from the rudiment data and MIDI events
    private func createStrokes(from rudiment: Rudiment, and midiFile: MIDIFile) -> [RudimentStroke] {
        // filter to note on events
        guard let events = midiFile.getEventsOf(type: .noteOn) else { return [] }
        
        let stickingPattern = rudiment.getStickingPattern()
        if stickingPattern.count != events.count {
            print("MIDI file is different length to rudiment data")
            print("events: \(events.count), expected: \(stickingPattern.count)")
            return []
        }
        
        var strokes: [RudimentStroke] = []
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
        
        return strokes
    }
    
    private func setupSequencer(_ rudiment: Rudiment,
                                _ length: Duration) {
        // plays at metronome start
        sequencer.loadMIDIFile(rudiment.midi)
        sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
        sequencer.setLength(length)
        midiCallback.callback = playStroke
    }
}
