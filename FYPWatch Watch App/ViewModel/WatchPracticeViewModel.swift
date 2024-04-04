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
    
    // TODO: rights predicted when playing left singles. (Stuck Buffer?? or motion updates failing?)
//    once solved, bring change to train branch
    private func didStartPlaying(_ isPlaying: Bool) {
        Task { 
            await MainActor.run { isStreamingMovement = isPlaying }
            if isPlaying {
                motionHandler.startDeviceMotionUpdates()
            } else {
                motionHandler.stopDeviceMotionUpdates()
                await buffer.removeAll()
            }
        }
    }
    
    // perform ML task for stroke request
    private func didPlayStroke(_ stroke: UserStroke) {
        Task {
            // get snapshot of motion data
            let snapshot = await buffer.getSnapshot(
                size: WINDOW_SIZE,
                with: stroke
            )
            
            var stroke = stroke
            stroke.motion = snapshot
            
            // send updated stroke to phone
            do {
                let strokeData = try JSONEncoder().encode(stroke)
                connectivityService.sendToPhone(["stroke": strokeData])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
