//
//  Extensions.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 13/03/2024.
//

import Foundation

extension WatchPracticeViewModel {
    
    func logGesture(snapshot: [MovementData]) {
        let features = [
            "timestamp",
            "rotationRateX",
            "rotationRateY",
            "rotationRateZ",
            "accelerationX",
            "accelerationY",
            "accelerationZ"
        ]
        
        var contents = ""
        
        // write features
        let featuresRow = features.joined(separator: ",")
        contents.append(featuresRow + "\n")
        
        // write data
        for datum in snapshot {
            let row = "\(datum.timestamp),\(datum.rotation.x),\(datum.rotation.y),\(datum.rotation.z),\(datum.acceleration.x),\(datum.acceleration.y),\(datum.acceleration.z)"
            contents.append(row + "\n")
        }
        // to train CoreML model with
        print(contents)
    }
}
