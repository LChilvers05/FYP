//
//  GestureRecognitionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreML
import Combine

final class GestureRecognitionHandler {
    
    private let state: MLState = .train
    private let watch = PhoneConnectivityService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let repository = Repository()
    
    private var strokeQueue = Queue<UserStroke>()
    private var buffer: [MovementData] = []
    private var prevOnsetTime = 0.0
    
    var didGetSticking: ((UserStroke) -> Void)?
    
    init() {
        watch.$stream
            .sink { [weak self] movementData in
                guard let self else { return }
                Task {
                    await self.updateBuffer(movementData)
                }
            }
            .store(in: &cancellables)
    }
    
    func enqueue(_ stroke: UserStroke) {
        // TODO: also do on same background thread
        strokeQueue.enqueue(stroke)
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke) {
        // TODO: classification of sticking
        didGetSticking?(stroke)
    }
    
    // console print for training data
    private func logGesture(for stroke: UserStroke) {
        let snapshot = getSnapshot(onsetTime: stroke.time)
        repository.logGesture(snapshot: snapshot)
    }
    
    private func getSnapshot(onsetTime: Double) -> [MovementData] {
        // movement window for analysis
        let snapshot = buffer.filter {
            $0.time >= prevOnsetTime && $0.time <= onsetTime
        }
        
        prevOnsetTime = onsetTime
        
        return snapshot
    }
    
    // check if sufficient movement to dequeue stroke
    private func checkQueue(_ movementData: MovementData) {
        guard var stroke = strokeQueue.peek(),
              stroke.time <= movementData.time else { return }
        stroke = strokeQueue.dequeue()!
        
        // perform ML task
        switch state {
        case .train:
            logGesture(for: stroke)
        case .predict:
            getSticking(for: stroke)
        }
    }
    
    // keep fixed length movement data buffer
    @MainActor //TODO: use same thread as enqueue()
    private func updateBuffer(_ movementData: MovementData?) {
        guard let movementData else { return }
        let bufferSize = 300
        buffer.append(movementData)
        if buffer.count > bufferSize { buffer.removeFirst() }
        
        checkQueue(movementData)
    }
}

enum MLState {
    case train, predict
}
