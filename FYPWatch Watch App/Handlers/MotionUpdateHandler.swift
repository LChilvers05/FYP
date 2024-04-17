//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion
import WatchKit

final class MotionUpdateHandler {
    
    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()
    private let updateInterval = 1.0/100.0 //100hz
    
    var didUpdateMotion: ((MotionData) -> Void)?
    
    var isDeviceMotionActive: Bool {
        motionManager.isDeviceMotionActive
    }
    
    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func startDeviceMotionUpdates(_ start: Date) {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        let latency = -start.timeIntervalSinceNow
        var startTimestamp: TimeInterval?
        
        // get acceleration, rotation and timestamp every interval
        motionManager.startDeviceMotionUpdates(to: operationQueue) { (data, error) in
            guard let acceleration = data?.userAcceleration,
                  let rotation = data?.rotationRate,
                  var timestamp = data?.timestamp,
                  error == nil else { return }
            
            // get time since motion update started
            if startTimestamp == nil {
                startTimestamp = timestamp
            }
            timestamp = (timestamp - (startTimestamp ?? timestamp)) + latency
            
            self.didUpdateMotion?(
                MotionData(
                    acceleration: acceleration,
                    rotation: rotation,
                    timestamp: timestamp
                )
            )
        }
    }
}
