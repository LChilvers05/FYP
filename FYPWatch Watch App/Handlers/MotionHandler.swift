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
    private let updateInterval = 1.0/1000.0 //1000hz
    // bundle into a common object
    private var movement: MovementData?
    
    func startMovementStream() {
        guard motionManager.isAccelerometerAvailable,
              motionManager.isGyroAvailable else { return }
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval
        
        // update common movement object
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.acceleration,
                  error == nil else { return }
            
            if self.movement == nil {
                self.movement = MovementData(time: 0.0)
            }
            
            self.movement?.acceleration = acceleration
            self.send(self.movement)
        }
        
        motionManager.startGyroUpdates(to: OperationQueue.main) { (data, error) in
            guard let rotation = data?.rotationRate,
                  error == nil else { return }
            
            if self.movement == nil {
                self.movement = MovementData(time: 0.0)
            }
            
            self.movement?.rotation = rotation
            self.send(self.movement)
        }
    }
    
    // send to phone when movement initialised
    private func send(_ movement: MovementData?) {
        guard let movement, movement.isInitialised() else { return }
        
        let message = ["movement": movement]
        connectivityService.sendToPhone(message)
        
        self.movement = nil
    }
}
