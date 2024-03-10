//
//  MidiComparisonHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 29/01/2024.
//

import AVFoundation
import AudioKit

// compare players input to rudiment data and return result
final class RudimentPlayer: ObservableObject {
    
    // nx3 for results buffer
    @Published var feedback: [[Feedback?]] = []
    // [UserStroke.id: (Expected Sticking, Results Index)]
    private var lookup: [Int: (Sticking, (Int, Int))] = [:]
    private var strokes: [RudimentStroke] = []
    private var focus = -1
    
    private let repository: Repository
    
    let sequencer = AppleSequencer() // play rudiment
    private let midiCallback = MIDICallbackInstrument()
    private let sequencerLength: Double // of sequencer
    
    private var isPlaying: Bool {
        get { return sequencer.isPlaying }
    }
    
    init(_ rudiment: Rudiment,
         length: Duration = Duration(beats: 4.0),
         _ repository: Repository) {
        self.repository = repository
        sequencerLength = length.beats
        let midiFile = repository.getRudimentMIDI(rudiment.midi)
        setupSequencer(rudiment, length)
        createStrokes(from: rudiment, and: midiFile)
    }
    
    // check user rhythm
    func scoreRhythm(for userStroke: UserStroke) {
        guard isPlaying else { return }
        Task {
            await compareRhythm(
                for: userStroke,
                curr: focus,
                next: focus+1
            )
        }
    }
    
    // check user sticking faults
    func checkSticking(for userStroke: UserStroke) {
        guard isPlaying else { return }
        Task {
            await compareSticking(for: userStroke)
        }
    }
    
    func rewind() {
        focus = -1
        lookup = [:]
        feedback = Array(
            repeating: Array(repeating: nil, count: strokes.count),
            count: 3
        )
    }
    
    // mark feedback
    @MainActor
    private func compareSticking(for userStroke: UserStroke) {
        guard let stroke = lookup[userStroke.id] else { return }
        
        if userStroke.sticking != stroke.0 {
            let i = stroke.1.0
            let j = stroke.1.1
            // mark sticking fault
            feedback[i][j] = .sticking
        }
        lookup.removeValue(forKey: userStroke.id)
    }
    
    // mark feedback
    @MainActor
    private func compareRhythm(for userStroke: UserStroke, curr: Int, next: Int) {
        // feedback list pointer
        var i = 1
        if curr < 0 { i = 0 }
        let curr = (curr + strokes.count) % strokes.count // wrap
        // index in feedback
        var feedbackIndex = (i, curr)
        // current midi stroke expected
        let stroke = strokes[curr]
        // compare rhythm
        let rhythm = stroke.checkRhythm(for: userStroke.positionInBeats)
        switch rhythm {
        case .early:
            // feedback for previous stroke
            compareRhythm(for: userStroke, curr: curr-1, next: curr)
        case .success, .late:
            // feedback for current stroke
            feedback[i][curr] = rhythm
        case .nextEarly, .nextSuccess:
            if next >= strokes.count || i == 0 { i += 1 }
            let next = (next + strokes.count) % strokes.count
            // feedback for next stroke
            feedback[i][next] = (rhythm == .nextEarly) ? .early : .success
            feedbackIndex = (i, next)
        default:
            feedback[i][curr] = rhythm
        }
        // update lookup table to use when sticking predicted
        lookup[userStroke.id] = (stroke.sticking, feedbackIndex)
    }
    
    // shift focus stroke as sequencer plays rudiment
    private func playStroke(status: MIDIByte, _: MIDIByte, _: MIDIByte) {
        guard let type = MIDIStatus(byte: status)?.type,
              type == .noteOn else { return } // note on
        Task {
            await MainActor.run {
                // check for missed strokes
                if focus >= 0 && feedback[1][focus] == nil {
                    feedback[1][focus] = .missed
                }
                // next event
                focus += 1
                
                // reset feedback results
                if focus == strokes.count {
                    focus = 0
                    // save prev feedback
                    repository.logPractice(feedback[0])
                    // shift along results buffer
                    feedback[0] = feedback[1]
                    feedback[1] = feedback[2]
                    feedback[2] = Array(repeating: nil, count: strokes.count)
                    
                    // update pointers in sticking lookup
                    for (userStrokeId, value) in lookup {
                        let i = value.1.0 - 1
                        if i < 0 {
                            lookup.removeValue(forKey: userStrokeId)
                            continue
                        }
                        lookup[userStrokeId]?.1.0 = i
                    }
                }
            }
        }
    }
    
    // initialise list of rudiment strokes from the rudiment data and MIDI events
    private func createStrokes(from rudiment: Rudiment, and midiFile: MIDIFile) {
        // filter to note on events
        guard let events = midiFile.getEventsOf(type: .noteOn) else { return }
        
        let stickingPattern = rudiment.getStickingPattern()
        if stickingPattern.count != events.count {
            print("MIDI file is different length to rudiment data")
            print("events: \(events.count), expected: \(stickingPattern.count)")
            return
        }
        
        strokes.removeAll()
        feedback.removeAll()
        
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
        
        feedback = Array(
            repeating: Array(repeating: nil, count: strokes.count),
            count: 3
        )
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

enum Feedback {
    case early,
         success,
         late,
         nextEarly,
         nextSuccess,
         missed,
         sticking,
         error
}
