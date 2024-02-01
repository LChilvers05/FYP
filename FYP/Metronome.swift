//
//  Metronome.swift
//  FYP
//
//  Created by Lee Chilvers on 30/01/2024.
//

import AudioKit
import SoundpipeAudioKit

final class Metronome {
    
    private let engine = AudioEngine()
    private let sequencer = AppleSequencer()
    private let instrument = MIDISampler()
    
    private let numerator: Int
    private let denominator: Int
    private var tempo: BPM
    
    private(set) var currentBeat = 0 //TODO: beat corresponding to it
    var isPlaying: Bool {
        get {
            return sequencer.isPlaying
        }
    }
    
    init(
        tempo: Int,
        numerator: Int = 4,
        denominator: Int = 1
    ) {
        self.tempo = BPM(tempo)
        self.numerator = numerator
        self.denominator = denominator
        // setup
        engine.output = instrument
        sequencer.setTempo(self.tempo.magnitude)
        sequencer.enableLooping()
        createTrack()
    }
    
    func start() {
        do {
            try engine.start()
            sequencer.play()
        } catch {
            print("Error starting metronome: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        sequencer.stop()
        engine.stop()
    }
    
    private func createTrack() {
        guard let track = sequencer.newTrack() else { return }
        let beatVelocity = MIDIVelocity(100)
        
        track.clear()
        track.setMIDIOutput(instrument.midiIn)
        track.setLength(Duration(beats: Double(numerator)))
        
        // downbeat
        track.add(
            noteNumber: MIDINoteNumber(6),
            velocity: beatVelocity,
            position: Duration(beats: 0.0),
            duration: Duration(beats: 0.4)
        )
        
        // remaining beats
        for beat in 1..<numerator {
            track.add(
                noteNumber: MIDINoteNumber(10),
                velocity: beatVelocity,
                position: Duration(beats: Double(beat)),
                duration: Duration(beats: 0.1)
            )
        }
    }
}
