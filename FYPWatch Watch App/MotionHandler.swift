//
//  MotionHandler.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import CoreMotion

final class MotionHandler {
    
    private let motionManager = CMMotionManager()
    private let connectivityService = ConnectivityService()
    
    func startAccelerometerSession() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            guard let acceleration = data?.acceleration,
                  error == nil else { return }
            
            let message = ["acceleration": acceleration]
            self.connectivityService.sendToPhone(message)
        }
    }
}
