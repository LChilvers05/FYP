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
    
    // prevent multiple detections per stroke
    private var previous = 0
    
    var didDetectOnset: ((AmplitudeData) -> Void)?
    
    init(threshold: Float = 0.3) {
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
        previous = 0
    }
    
    private func detectOnset(_ ampData: AmplitudeData?) {
        guard let ampData,
              ampData.id != previous + 1,
              ampData.amplitude >= threshold else { return }
        
        didDetectOnset?(ampData)
        previous = ampData.id
    }
}
