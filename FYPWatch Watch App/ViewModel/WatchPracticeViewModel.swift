//
//  StickingRecognitionHandler2.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 13/03/2024.
//

import Combine
import WatchKit

final class WatchPracticeViewModel: ObservableObject {
    
    @Published private(set) var isStreamingMovement = false

    private let connectivityService = WatchConnectivityService.shared
    private let motionHandler = MotionUpdateHandler()
    private var cancellables: Set<AnyCancellable> = []
    
    private let buffer = MotionBuffer(size: 100)
    
    private let state: MLState = .train
    private let windowSize = 20
    private var stickingClassifier: StickingClassifierHandler?
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didPlayStroke = didPlayStroke
        motionHandler.$stream
            .sink { [weak self] movementData in
                guard let self, let movementData else { return }
                Task { await self.buffer.add(movementData) }
            }
            .store(in: &cancellables)
    }
    
    private func didStartPlaying(_ isPlaying: Bool) {
        Task { await MainActor.run { isStreamingMovement = isPlaying }}
        if isPlaying {
            stickingClassifier = try? StickingClassifierHandler(windowSize)
            motionHandler.startDeviceMotionUpdates()
        } else {
            motionHandler.stopDeviceMotionUpdates()
            Task { await buffer.removeAll() }
        }
    }
    
    // perform ML task for stroke request
    private func didPlayStroke(_ stroke: UserStroke) {
        Task {
            // get snapshot of motion data
            let snapshot = await buffer.getSnapshot(
                size: windowSize,
                with: stroke
            )
            switch state {
            case .train:
                logGesture(snapshot: snapshot)
            case .predict:
                await getSticking(for: stroke, from: snapshot)
            }
        }
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke,
                             from snapshot: [MotionData]) async {
        guard let stickingClassifier,
              let sticking = await stickingClassifier.predict(snapshot)
        else { return }
        var stroke = stroke; stroke.sticking = sticking
        
        // send updated stroke to phone
        do {
            let strokeData = try JSONEncoder().encode(stroke)
            connectivityService.sendToPhone(["stroke": strokeData])
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
