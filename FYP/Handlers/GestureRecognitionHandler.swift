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
    private let connectivityService = PhoneConnectivityService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let repository = Repository()
    
    private var strokeQueue = Queue<UserStroke>() // thread safe
    private var buffer: [MovementData] = []
    private var prevOnsetTime = 0.0
    
    var didGetSticking: ((UserStroke) -> Void)?
    
    init() {
        connectivityService.$stream
            .sink { [weak self] movementData in
                guard let self else { return }
                Task {
                    await self.updateBuffer(movementData)
                }
            }
            .store(in: &cancellables)
    }
    
    func startRecognition() {
        connectivityService.sendToWatch(["is_playing": true])
    }
    
    func endRecognition() {
        connectivityService.sendToWatch(["is_playing": false])
    }
    
    func enqueue(_ stroke: UserStroke) {
        Task { await strokeQueue.enqueue(stroke) }
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke) {
        // TODO: classification of sticking
        // stroke.sticking = .left
        didGetSticking?(stroke)
    }
    
    // console print for training data
    private func logGesture(for stroke: UserStroke) {
        let snapshot = getSnapshot(onsetTime: stroke.timestamp)
        repository.logGesture(snapshot: snapshot)
    }
    
    private func getSnapshot(onsetTime: Double) -> [MovementData] {
        // movement window for analysis
        let snapshot = buffer.filter {
            $0.timestamp >= prevOnsetTime && $0.timestamp <= onsetTime
        }
        
        prevOnsetTime = onsetTime
        
        return snapshot
    }
    
    // check if sufficient movement to dequeue stroke
    private func checkQueue(_ movementData: MovementData) async {
        guard var stroke = await strokeQueue.peek(),
              stroke.timestamp <= movementData.timestamp else { return }
        stroke = await strokeQueue.dequeue()!
        
        // perform ML task
        switch state {
        case .train:
            logGesture(for: stroke)
        case .predict:
            getSticking(for: stroke)
        }
    }
    
    // keep fixed length movement data buffer
    private func updateBuffer(_ movementData: MovementData?) async {
        guard let movementData else { return }
        let bufferSize = 1000
        buffer.append(movementData)
        if buffer.count > bufferSize { buffer.removeFirst() }
        
        print(movementData.timestamp)
        
        await checkQueue(movementData)
    }
}

enum MLState {
    case train, predict
}
