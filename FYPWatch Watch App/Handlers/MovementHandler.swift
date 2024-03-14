//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion
import WatchKit

final class MovementHandler: ObservableObject {
    
    @Published private(set) var stream: MovementData? = nil
    
    private let motionManager = CMMotionManager()
    private let updateInterval = 1.0/100.0 //100hz
    
    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        var startTimestamp: TimeInterval?
        // get acceleration, rotation and timestamp every interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.userAcceleration,
                  let rotation = data?.rotationRate,
                  let deviceTimestamp = data?.timestamp,
                  error == nil else { return }
            
            // get time since motion update started
            var timestamp = deviceTimestamp
            if startTimestamp == nil {
                startTimestamp = timestamp
            }
            timestamp -= startTimestamp ?? timestamp
            
            // publish to listeners
            self.stream = MovementData(
                acceleration: acceleration,
                rotation: rotation,
                timestamp: timestamp
            )
        }
    }
}
