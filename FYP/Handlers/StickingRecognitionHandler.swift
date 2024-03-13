//
//  GestureRecognitionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreML
import Combine

final class StickingRecognitionHandler {
    
    private let connectivityService = PhoneConnectivityService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let repository: Repository
    
    private let state: MLState = .predict
    private var stickingHandler: StickingClassifierHandler?
    
    private let strokeCount: Int
    private var strokes = Queue<UserStroke>() // thread safe
    private let bufferSize = 20
    private var buffer = Queue<MovementData>()
    
    private var isPlaying = false
    
    var didGetSticking: ((UserStroke) -> Void)?
    
    init(_ repository: Repository, _ strokeCount: Int) {
        self.repository = repository
        self.strokeCount = strokeCount
        connectivityService.$stream
            .sink { [weak self] movementData in
                guard let self, self.isPlaying else { return }
                Task {
                    await self.updateBuffer(movementData)
                }
            }
            .store(in: &cancellables)
    }
    
    func startRecognition() {
        isPlaying = true
        stickingHandler = try? StickingClassifierHandler(windowSize: bufferSize)
        connectivityService.sendToWatch(["is_playing": isPlaying])
    }
    
    func stopRecognition() {
        isPlaying = false
        connectivityService.sendToWatch(["is_playing": isPlaying])
        Task {
            await strokes.removeAll()
            await buffer.removeAll()
        }
    }
    
    // add onset waiting for sticking classification
    func enqueue(_ stroke: UserStroke) {
        Task {
            await strokes.enqueue(stroke)
            // fixed length backlog of classifications
            if await strokes.count > (strokeCount * 2) {
                let _ = await strokes.dequeue()
            }
        }
    }
    
    // predict using model
    private func getSticking(for stroke: UserStroke,
                             from snapshot: [MovementData]) async {
        guard let stickingHandler,
              let sticking = await stickingHandler.classifySticking(from: snapshot)
        else { return }
        var stroke = stroke; stroke.sticking = sticking
        didGetSticking?(stroke)
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
            repository.logGesture(snapshot: snapshot)
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

enum MLState {
    case train, predict
}
