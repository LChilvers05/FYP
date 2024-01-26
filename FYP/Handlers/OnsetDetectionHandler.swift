//
//  OnsetDetectionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import Accelerate
import AVFoundation
import Combine

final class OnsetDetectionHandler {
    
    private let audioService = AudioService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    //TODO: subscribes to timer (metronome)?
    
    init() {
        audioService.$stream
            .sink { [weak self] buffer in
                if let buffer {
                    self?.detectOnsets(within: buffer)
                }
            }
            .store(in: &cancellables)
    }
    
    private func detectOnsets(within buffer: ([Float], AVAudioTime)) {
        let (samples, start) = buffer
        let windowSize = 100
        
        var ampEnvelope = [Float](
            repeating: 0.0,
            count: samples.count - windowSize + 1
        )
        // compute moving average with convolution
        vDSP_conv(
            samples, 1,
            [Float](repeating: 1.0 / Float(windowSize),count: windowSize),
            1, &ampEnvelope, 1,
            vDSP_Length(ampEnvelope.count),
            vDSP_Length(windowSize)
        )
        
        //onset if over threshold
        let threshold: Float = 0.5
        let onsets = ampEnvelope.map { $0 > threshold ? 1 : 0 }
        
        //TODO: how to map envelope to times there is a hit?
    }
}
