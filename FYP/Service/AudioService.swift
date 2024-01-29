//
//  AudioService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import AVFoundation
import Combine

final class AudioService: ObservableObject {
    
    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var inputNode: AVAudioInputNode?
    var sampleInterval: Double = 0.0
    // buffer of samples to subscribe to
    @Published var stream: ([Float], AVAudioTime)? = nil
    
    static let shared = AudioService()
    private init() {
        // setup
        try? session.setCategory(.record, mode: .default, options: [])
        let inputNode = engine.inputNode,
            format = inputNode.inputFormat(forBus: 0),
            bufferSize = AVAudioFrameCount(format.sampleRate) //48000
        sampleInterval = 1/format.sampleRate
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
    
    private func handleAudio(_ buffer: AVAudioPCMBuffer, start: AVAudioTime) {
        guard let frames = buffer.floatChannelData?[0] else { return } //mono
        var samples: [Float] = []
        // frame length = 19120
        for i in 0..<Int(buffer.frameLength) {
            // normalise
            samples.append(max(-1.0, min(1.0, frames[i])))
        }
        // update subscribers
        stream = (samples, start)
    }
}
