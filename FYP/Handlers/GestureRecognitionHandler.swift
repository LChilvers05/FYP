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
    
    private var movement: [MovementData] = [] //buffer
    private var prevOnsetTime = 0.0
    
    func getSticking(onsetTime: Double) -> Sticking {
        let snapshot = getSnapshot(onsetTime: onsetTime)
//        let model = SomeModel()
//        let prediction = model.predict(snapshot)
        return .right
    }
    
    func logGesture(onsetTime: Double) {
        let snapshot = getSnapshot(onsetTime: onsetTime)
        repository.logGesture(snapshot: snapshot)
    }
    
    private func getSnapshot(onsetTime: Double) -> [MovementData] {
        // TODO: find the local maxima
        // from prevOnsetTime to onsetTime
        let max: MovementData? = nil
        guard let max else { return [] }
        
        // shift movement by latency
        let latency = max.time - prevOnsetTime
        for (i, _) in movement.enumerated() {
            movement[i].time -= latency
        }
        prevOnsetTime = onsetTime
        
        // do analysis
        let snapshot = movement.filter {
            $0.time >= max.time && $0.time <= onsetTime
        }
        
        return snapshot
    }
}
