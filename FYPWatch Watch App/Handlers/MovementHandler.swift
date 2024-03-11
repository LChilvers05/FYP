//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion
import WatchKit

final class MovementHandler: ObservableObject {
    
    @Published var isStreamingMovement = false
    
    private let motionManager = CMMotionManager()
    private let connectivityService = WatchConnectivityService.shared
    private let updateInterval = 1.0/100.0 //100hz
    private var startTimeStamp: TimeInterval?
    
    init() {
        connectivityService.didStartPlaying = didStartPlaying
        connectivityService.didStopPlaying = didStopPlaying
    }
    
    private func didStartPlaying() {
        startMovementStream()
    }
    
    private func didStopPlaying() {
        Task { await MainActor.run { isStreamingMovement = false }}
        startTimeStamp = nil
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func startMovementStream() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        Task { await MainActor.run { isStreamingMovement = true }}
        
        // get acceleration, rotation and timestamp every interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.userAcceleration,
                  let rotation = data?.rotationRate,
                  let deviceTimestamp = data?.timestamp,
                  error == nil else { return }
            
            // get time since motion update started
            var timestamp = deviceTimestamp
            if self.startTimeStamp == nil {
                self.startTimeStamp = timestamp
            }
            timestamp -= self.startTimeStamp ?? timestamp
            
            // encode for iPhone
            do {
                let movement = try JSONEncoder().encode(
                    MovementData(
                        acceleration: acceleration,
                        rotation: rotation,
                        timestamp: timestamp
                    )
                )
                self.connectivityService.sendToPhone(["movement": movement])
            } catch {
                print("Failed to encode MovementData: \(error.localizedDescription)")
            }
        }
    }
}
