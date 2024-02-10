//
//  GestureRecognitionHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 10/02/2024.
//

import CoreML
import Combine

final class GestureRecognitionHandler {
    
    private let watch = PhoneConnectivityService.shared
    private var cancellables: Set<AnyCancellable> = []
    private let repository = Repository()
    
    private var buffer: [MovementData] = []
    private var prevOnsetTime = 0.0
    
    init() {
        watch.$stream
            .sink { [weak self] movementData in
                guard let self else { return }
                self.updateBuffer(movementData)
            }
            .store(in: &cancellables)
    }
    
    // predict using model
    func getSticking(onsetTime: Double) {}
    
    // console print for training data
    func logGesture(onsetTime: Double) {
        let snapshot = getSnapshot(onsetTime: onsetTime)
        repository.logGesture(snapshot: snapshot)
    }
    
    private func getSnapshot(onsetTime: Double) -> [MovementData] {
        guard let strokeTime = getStrokeTime(
            in: buffer,
            between: prevOnsetTime,
            and: onsetTime
        ) else { return [] }
        
        // shift movement by latency
        let latency = strokeTime - prevOnsetTime
        for (i, _) in buffer.enumerated() {
            buffer[i].time -= latency
        }
        prevOnsetTime = onsetTime
        
        // movement window for analysis
        let snapshot = buffer.filter {
            $0.time >= strokeTime && $0.time <= onsetTime
        }
        
        return snapshot
    }
    
    // estimate time gesture to make sound completes
    private func getStrokeTime(in movementData: [MovementData],
                              between start: Double,
                              and end: Double) -> Double? {
        // find local peak in focus window
        guard let i = buffer.firstIndex(where: { $0.time >= start }),
              let j = buffer.firstIndex(where: { $0.time >= end })
        else { return nil }
        let movement = buffer[i...j]
        let localPeak = movement.max(by: {
            guard let acc1 = $0.acceleration,
                  let acc2 = $1.acceleration else { return false }
            return acc1.z < acc2.z
        })
        return localPeak?.time
    }
    
    // keep fixed length movement data buffer
    private func updateBuffer(_ movementData: MovementData?) {
        // TODO: research thread safety (for rudimentPlayer too)
        guard let movementData else { return }
        let bufferSize = 300
        buffer.append(movementData)
        if buffer.count > bufferSize { buffer.removeFirst() }
    }
}
