//
//  Metronome.swift
//  FYP
//
//  Created by Lee Chilvers on 30/01/2024.
//

import AudioKit
import SoundpipeAudioKit
import Combine
import Foundation

// plays click and points to current beat
final class Metronome: ObservableObject {
    
    @Published var beat: Int = 0
    
    private let engine = AudioEngine()
    private let sequencer = AppleSequencer()
    private let midiCallback = MIDICallbackInstrument()
    private let instrument = Oscillator()
    
    // time signature
    private let numerator: Int
    private let denominator: Int
    
    var tempo: Int {
        get { Int(sequencer.tempo) }
        set { sequencer.setTempo(Double(newValue)) }
    }
    
    private(set) var isCountingIn = true
    var isPlaying: Bool {
        get { return sequencer.isPlaying }
    }
    
    init(tempo: Int, numerator: Int = 4, denominator: Int = 4) {
        self.numerator = numerator
        self.denominator = denominator
        self.tempo = tempo
        
        // setup
        createTrack()
        sequencer.enableLooping()
        
        midiCallback.callback = playNote
        
        engine.output = instrument
        try? engine.start()
    }
    
    func start() {
        guard !isPlaying else { return }
        beat = 0
        isCountingIn = true
        sequencer.rewind()
        sequencer.play()
    }
    
    func stop() {
        guard isPlaying else { return }
        instrument.stop()
        sequencer.stop()
    }
    
    private func createTrack() {
        guard let track = sequencer.newTrack() else { return }
        let beatVelocity = MIDIVelocity(100)
        
        track.clear()
        track.setMIDIOutput(midiCallback.midiIn)
        track.setLength(Duration(beats: Double(numerator)))
        
        // downbeat
        track.add(
            noteNumber: MIDINoteNumber(80), // pitch
            velocity: beatVelocity,         // dynamics
            position: Duration(beats: 0.0), // start time
            duration: Duration(beats: 0.05) // length of note
        )
        
        // remaining beats
        for beat in 1..<numerator {
            track.add(
                noteNumber: MIDINoteNumber(70),
                velocity: beatVelocity,
                position: Duration(beats: Double(beat)),
                duration: Duration(beats: 0.05)
            )
        }
    }
    
    private func playNote(status: MIDIByte, note: MIDIByte, velocity: MIDIByte) {
        if status == 144 { // note on
            countBeat()
            instrument.frequency = note.midiNoteToFrequency()
            instrument.amplitude = AUValue(velocity)
            instrument.play()
        } else if status == 128 { // note off
            instrument.amplitude = 0.0
        }
    }
    
    private func countBeat() {
        if beat == numerator {
            beat = 1
            isCountingIn = false
        } else {
            beat += 1
        }
    }
    
    deinit {
        stop()
        engine.stop()
    }
}