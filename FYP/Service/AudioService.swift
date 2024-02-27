//
//  AudioService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import AudioKit
import AudioKitEX
import Combine

// opens audio amplitude data stream
final class AudioService: ObservableObject {
    
    @Published var stream: AmplitudeData? = nil
    
    private let engine = AudioEngine()
    private var tap: AmplitudeTap?
    private var isTapOn = false
    private(set) var mic: AudioEngine.InputNode?
    
    static let shared = AudioService()
    private init() {
        guard let mic = engine.input else { return }
        //setup
        self.mic = mic
        engine.output = Fader(mic, gain: 0) //silence
        tap = AmplitudeTap(
            mic,
            analysisMode: .peak,
            callbackQueue: .global(qos: .userInitiated)
        ) { [weak self] amplitude in
            guard let self,
                  self.isTapOn else { return }
            self.handle(amplitude)
        }
    }
    
    func startListening() {
        guard let tap,
              !isTapOn else { return }
        //start mic and open amp tap
        try? engine.start()
        tap.start()
        isTapOn = true
    }
    
    func stopListening() {
        engine.stop()
        isTapOn = false
    }
    
    private func handle(_ amplitude: AUValue) {
        // update subscribers
        stream = AmplitudeData(amplitude: amplitude)
    }
}
