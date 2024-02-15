//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion

final class MovementHandler: ObservableObject {
    
    @Published var isStreamingMovement = false
    
    private let motionManager = CMMotionManager()
    private let connectivityService = WatchConnectivityService.shared
    private let updateInterval = 1.0/1000.0 //1000hz
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didStopPlaying = didStopPlaying
    }
    
    private func didStartPlaying() {
        startMovementStream()
    }
    
    private func didStopPlaying() {
        isStreamingMovement = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    private func startMovementStream() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        isStreamingMovement = true
        
        // get acceleration, rotation and timestamp every interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.userAcceleration,
                  let rotation = data?.rotationRate,
                  let timestamp = data?.timestamp,
                  error == nil else { return }
            do {
                let movement = try JSONEncoder().encode(
                    MovementData(
                        acceleration: acceleration,
                        rotation: rotation,
                        timestamp: timestamp
                    )
                )
                // send to iPhone
                self.connectivityService.sendToPhone(["movement": movement])
            } catch {
                print("Failed to encode MovementData: \(error.localizedDescription)")
            }
        }
    }
}
