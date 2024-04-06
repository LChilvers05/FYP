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
    
    private let audioService = AudioService.shared
    private let engine = AudioEngine()
    private let midiCallback = MIDICallbackInstrument()
    private let instrument = Oscillator()
    private let sequencer: AppleSequencer
    
    private var latency: Double {
        get { // TODO: let x = audioService.mic?.avAudioNode.latency
            let k = 1.9/1000
            return k*Double(sequencer.tempo)
        }
    }
    var isPlaying: Bool {
        get { sequencer.isPlaying }
    }
    var positionInBeats: Double {
        get {
            (sequencer.currentPosition.beats - latency)
                .truncatingRemainder(dividingBy: sequencer.length.beats)
        }
    }
    var timeElapsed: Double {
        get {
            sequencer.seconds(
                duration: Duration(
                    beats: sequencer.currentPosition.beats - latency
                )
            )
        }
    }
    
    init(sequencer: AppleSequencer) {
        self.sequencer = sequencer
        
        // setup
        createTrack()
        
        engine.output = instrument
        try? engine.start()
    }
    
    func start() {
        guard !isPlaying else { return }
        beat = 0
        sequencer.rewind()
        sequencer.play()
    }
    
    func stop() {
        guard isPlaying else { return }
        instrument.stop()
        sequencer.stop()
    }
    
    func update(_ tempo: Int) {
        sequencer.setTempo(Double(tempo))
    }
    
    private func createTrack() {
        guard let track = sequencer.newTrack() else { return }
        let beatVelocity = MIDIVelocity(127)
        
        track.clear()
        track.setMIDIOutput(midiCallback.midiIn)
        track.setLength(sequencer.length)
        
        // downbeat
        track.add(
            noteNumber: MIDINoteNumber(80), // pitch
            velocity: beatVelocity,         // dynamics
            position: Duration(beats: 0.0), // start time
            duration: Duration(beats: 0.05) // length of note
        )
        
        // remaining beats
        for beat in 1..<Int(sequencer.length.beats) {
            track.add(
                noteNumber: MIDINoteNumber(70),
                velocity: beatVelocity,
                position: Duration(beats: Double(beat)),
                duration: Duration(beats: 0.05)
            )
        }
        
        sequencer.enableLooping()
        midiCallback.callback = playNote
    }
    
    private func playNote(status: MIDIByte, note: MIDIByte, velocity: MIDIByte) {
        guard let type = MIDIStatus(byte: status)?.type else { return }
        switch type {
        case .noteOff:
            instrument.amplitude = 0.0
        case .noteOn:
            countBeat()
            instrument.frequency = note.midiNoteToFrequency()
            instrument.amplitude = AUValue(velocity)
            instrument.play()
        default:
            break
        }
    }
    
    private func countBeat() {
        beat = (beat % Int(sequencer.length.beats)) + 1
    }
    
    deinit {
        stop()
        engine.stop()
    }
}
