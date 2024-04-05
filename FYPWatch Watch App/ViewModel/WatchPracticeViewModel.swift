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
    private let strokes = Queue<UserStroke>()
    
    private let isLogging = true
    private let windowSize = 10 // 1 tenth of a second
    private var stickingClassifier: StickingClassifierHandler?
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didStopPlaying = didStopPlaying
        connectivityService.didPlayStroke = didPlayStroke
        motionHandler.didUpdateMotion = didUpdateMotion
    }
    
    private func didStartPlaying(_ start: Date) async {
        stickingClassifier = try? StickingClassifierHandler(windowSize)
        motionHandler.startDeviceMotionUpdates(start)
        await MainActor.run {
            isStreamingMovement = motionHandler.isDeviceMotionActive
        }
    }
    
    private func didStopPlaying() async {
        motionHandler.stopDeviceMotionUpdates()
        await buffer.removeAll()
        await strokes.removeAll()
        await MainActor.run {
            isStreamingMovement = motionHandler.isDeviceMotionActive
        }
    }
    
    private func didPlayStroke(_ stroke: UserStroke) async {
        await strokes.enqueue(stroke)
    }
    
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
    
    private func checkStrokeRequests() async {
        // check sufficient motion to fulfill request
        guard let lastMotion = await buffer.elements.last,
              let peek = await strokes.peek(),
              peek.timestamp <= lastMotion.timestamp,
              let stroke = await strokes.dequeue() else { return }
        
        // get snapshot of motion data
        let snapshot = await buffer.getSnapshot(
            size: windowSize,
            with: stroke
        )
        
        if isLogging { logGesture(snapshot: snapshot) }
        
        // classify
        await getSticking(for: stroke, from: snapshot)
    }
    
    private func didUpdateMotion(_ motionData: MotionData) {
        Task { 
            await buffer.add(motionData)
            await checkStrokeRequests()
        }
    }
}
