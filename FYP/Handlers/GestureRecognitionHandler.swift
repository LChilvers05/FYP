//
//  GestureRecognitionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreML
import Combine

final class GestureRecognitionHandler {
    
    private let connectivityService = PhoneConnectivityService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let repository = Repository()
    
    private let state: MLState = .predict
    private let stickingHandler: StickingClassifierHandler?
    
    private var strokeQueue = Queue<UserStroke>() // thread safe
    private var buffer = Queue<MovementData>()
    private var prevOnsetTime = 0.0
    
    var didGetSticking: ((UserStroke) -> Void)?
    
    init() {
        stickingHandler = try? StickingClassifierHandler()
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
    
    // add onset waiting for sticking classification
    func enqueue(_ stroke: UserStroke) {
        Task { await strokeQueue.enqueue(stroke) }
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke) async {
        let snapshot = await getSnapshot(onsetTime: stroke.timestamp)
        guard let stickingHandler,
              let sticking = stickingHandler.classifySticking(from: snapshot)
        else { return }
//        didGetSticking?(stroke)
    }
    
    // movement snapshot for classification
    private func getSnapshot(onsetTime: Double) async -> [MovementData] {
        let snapshot = await buffer.elements.filter {
            $0.timestamp >= prevOnsetTime && $0.timestamp <= onsetTime
        }
        prevOnsetTime = onsetTime
        
        return snapshot
    }
    
    // check if sufficient movement to dequeue stroke
    private func checkQueue(_ movementData: MovementData) async {
        guard let peek = await strokeQueue.peek(),
              peek.timestamp <= movementData.timestamp,
              let stroke = await strokeQueue.dequeue() else { return }
        
        // perform ML task
        switch state {
        case .train:
            await logGesture(for: stroke)
        case .predict:
            await getSticking(for: stroke)
        }
    }
    
    // keep fixed length movement data buffer
    private func updateBuffer(_ movementData: MovementData?) async {
        guard let movementData else { return }
        let bufferSize = 100
        await buffer.enqueue(movementData)
        if await buffer.count > bufferSize {
            let _ = await buffer.dequeue()
        }
        
        await checkQueue(movementData)
    }
}

extension GestureRecognitionHandler {
    // console print for training data
    private func logGesture(for stroke: UserStroke) async  {
        let snapshot = await getSnapshot(onsetTime: stroke.timestamp)
        repository.logGesture(snapshot: snapshot)
    }
}

enum MLState {
    case train, predict
}
