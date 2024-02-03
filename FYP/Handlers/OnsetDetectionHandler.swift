//
//  OnsetDetectionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import Combine

// subscribes audio amplitude data stream and detects onsets
final class OnsetDetectionHandler {
    
    private let audioService = AudioService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let threshold: Float
    
    var didDetectOnset: ((AmplitudeData?) -> Void)?
    
    init(threshold: Float = 0.1) {
        self.threshold = threshold
        audioService.$stream
            .sink { [weak self] ampData in
                guard let self else { return }
                self.detectOnset(ampData)
            }
            .store(in: &cancellables)
    }
    
    func beginDetecting() {
        audioService.startListening()
    }
    
    func stopDetecting() {
        audioService.stopListening()
    }
    
    private func detectOnset(_ ampData: AmplitudeData?) {
        guard let amplitude = ampData?.amplitude,
              let serial =  ampData?.id else { return }
        
        //TODO: 
        if amplitude >= threshold {
            print("\(serial): \(amplitude.magnitude)")
            didDetectOnset?(ampData)
        }
    }
}
