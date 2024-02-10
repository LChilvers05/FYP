//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion

final class MotionHandler {
    
    private let motionManager = CMMotionManager()
    private let connectivityService = WatchConnectivityService.shared
    
    func startAccelerometerStream() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0/1000.0 //1000hz
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.acceleration,
                  error == nil else { return }
            
            let message = ["acceleration": acceleration]
            self.connectivityService.sendToPhone(message)
        }
    }
    
    func startGyroStream() {
        guard motionManager.isGyroAvailable else { return }
        
        motionManager.gyroUpdateInterval = 1.0/1000.0 //1000hz
        motionManager.startGyroUpdates(to: OperationQueue.main) { (data, error) in
            guard let rotationRate = data?.rotationRate,
                  error == nil else { return }
            
            let message = ["rotation_rate": rotationRate]
            self.connectivityService.sendToPhone(message)
        }
    }
}
