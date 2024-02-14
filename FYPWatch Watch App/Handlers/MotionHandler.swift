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
    // populate movement -> send -> repeat
    private var movement: MovementData?
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didStopPlaying = didStopPlaying
    }
    
    private func didStartPlaying() {
        startMovementStream()
    }
    
    private func didStopPlaying() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    private func startMovementStream() {
        guard motionManager.isAccelerometerAvailable,
              motionManager.isGyroAvailable else { return }
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval
        
        // update a common movement object
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.acceleration,
                  let timestamp = data?.timestamp, // TODO: check
                  error == nil else { return }
            
            if self.movement == nil {
                self.movement = MovementData(timestamp)
            }
            
            self.movement?.acceleration = acceleration
            self.send(self.movement)
        }
        
        motionManager.startGyroUpdates(to: OperationQueue.main) { (data, error) in
            guard let rotation = data?.rotationRate,
                  let timestamp = data?.timestamp,
                  error == nil else { return }
            
            if self.movement == nil {
                self.movement = MovementData(timestamp)
            }
            
            self.movement?.rotation = rotation
            self.send(self.movement)
        }
    }
    
    // send to phone when movement initialised
    private func send(_ movement: MovementData?) {
        guard let movement, movement.isInitialised() else { return }
        connectivityService.sendToPhone(["movement": movement])
        self.movement = nil
    }
}
