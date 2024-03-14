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
    private let movementHandler = MovementHandler()
    private var cancellables: Set<AnyCancellable> = []
    
    private let bufferSize = 20
    private let buffer = Queue<MovementData>()
    private var strokes = Queue<UserStroke>()
    
    private let state: MLState = .predict
    private var stickingClassifier: StickingClassifierHandler?
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didPlayStroke = didPlayStroke
        movementHandler.$stream
            .sink { [weak self] movementData in
                guard let self else { return }
                Task {
                    await self.updateBuffer(movementData)
                }
            }
            .store(in: &cancellables)
    }
    
    private func didStartPlaying(_ isPlaying: Bool) {
        Task { await MainActor.run { isStreamingMovement = isPlaying }}
        if isPlaying {
            stickingClassifier = try? StickingClassifierHandler(windowSize: bufferSize)
            movementHandler.startDeviceMotionUpdates()
        } else {
            movementHandler.stopDeviceMotionUpdates()
            Task {
                await strokes.removeAll()
                await buffer.removeAll()
            }
        }
    }
    
    private func didPlayStroke(_ userStroke: UserStroke) {
        Task { await strokes.enqueue(userStroke) }
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke,
                             from snapshot: [MovementData]) async {
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
    
    // check if sufficient movement to dequeue stroke
    private func checkQueue(_ movementData: MovementData) async {
        guard let peek = await strokes.peek(),
              peek.timestamp <= movementData.timestamp,
              let stroke = await strokes.dequeue() else { return }
        
        let snapshot = await buffer.elements
        await buffer.removeAll()
        
        // perform ML task
        switch state {
        case .train:
            logGesture(snapshot: snapshot)
        case .predict:
            await getSticking(for: stroke, from: snapshot)
        }
    }
    
    // keep fixed length movement data buffer
    private func updateBuffer(_ movementData: MovementData?) async {
        guard let movementData else { return }
        await buffer.enqueue(movementData)
        if await buffer.count > bufferSize {
            let _ = await buffer.dequeue()
        }
        
        await checkQueue(movementData)
    }
}
