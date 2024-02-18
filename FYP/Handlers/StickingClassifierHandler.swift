//
//  StickingClassifierHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 18/02/2024.
//

import CoreML

final class StickingClassifierHandler {
    
    private let model: DrumStrokeClassifier_1
    private let windowSize = 100
    private let stateInSize = 400
    private let accXML, accYML, accZML: MLMultiArray
    private let rotXML, rotYML, rotZML: MLMultiArray
    private let stateIn: MLMultiArray
    
    init() throws {
        model = try DrumStrokeClassifier_1(configuration: MLModelConfiguration())
        accXML = try multiArray(windowSize)
        accYML = try multiArray(windowSize)
        accZML = try multiArray(windowSize)
        rotXML = try multiArray(windowSize)
        rotYML = try multiArray(windowSize)
        rotZML = try multiArray(windowSize)
        stateIn = try multiArray(stateInSize)
    }
    
    func classifySticking(from snapshot: [MovementData]) -> Sticking? {
        // correct data type for snapshot
        let index = max(0, snapshot.count - windowSize)
        for (i, datum) in snapshot[index..<snapshot.count].prefix(windowSize).enumerated() {
            accXML[i] = NSNumber(value: datum.accX)
            accYML[i] = NSNumber(value: datum.accY)
            accZML[i] = NSNumber(value: datum.accZ)
            rotXML[i] = NSNumber(value: datum.rotX)
            rotYML[i] = NSNumber(value: datum.rotY)
            rotZML[i] = NSNumber(value: datum.rotZ)
        }
        
        // make prediction
        do {
            let prediction = try model.prediction(
                AccelerationX: accXML,
                AccelerationY: accYML,
                AccelerationZ: accZML,
                RotationRateX: rotXML,
                RotationRateY: rotYML,
                RotationRateZ: rotZML,
                stateIn: stateIn
            )
            
            return (prediction.label == "right") ? .right
            : (prediction.label == "left") ? .left
            : nil
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    private let multiArray: (Int) throws -> MLMultiArray = { size in
        try MLMultiArray(shape: [NSNumber(integerLiteral: size)], dataType: .double)
    }
}
