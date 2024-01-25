//
//  AudioService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import AVFoundation

final class AudioService {
    
    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var inputNode: AVAudioInputNode?
    
    static let shared = AudioService()
    private init() {
        // setup
        try? session.setCategory(.record, mode: .default, options: [])
        let inputNode = engine.inputNode,
            format = inputNode.inputFormat(forBus: 0),
            bufferSize = AVAudioFrameCount(format.sampleRate)
        // handle the stream of audio
        inputNode.installTap(
            onBus: 0,
            bufferSize: bufferSize,
            format: format
        ) { (buffer, time) in
            // in background
            self.handleAudio(buffer, start: time)
        }
        engine.prepare()
        self.inputNode = inputNode
    }
    
    func startListening() {
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            try engine.start()
        } catch {
            print("Error starting audio stream: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        do {
            engine.stop()
            inputNode?.removeTap(onBus: 0)
            try session.setActive(false)
        } catch {
            print("Error stopping audio stream: \(error.localizedDescription)")
        }
    }
    
    // TODO:
    // 1. process audio in real-time
    // 2. compare to movement data
    // 3. create MIDI events
    // 4. compare MIDI events to MIDI file events
    
    private func handleAudio(_ buffer: AVAudioPCMBuffer, start: AVAudioTime) {
        guard let floatChannelData = buffer.floatChannelData,
              buffer.format.channelCount == 1 else { return } //mono
        
        // frame length = 19120
        // sample rate = 48000
        // 1 sample per frame (mono)
//        for frame in 0..<Int(buffer.frameLength) {
//            print(frame)
//            let sample = floatChannelData[0][frame],
//                normalisedSample = max(-1.0, min(1.0, sample))
//        }
    }
}
