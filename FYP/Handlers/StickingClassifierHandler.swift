//
//  StickingClassifierHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 18/02/2024.
//

import CoreML

final class StickingClassifierHandler {
    
    private let model: StickingClassifier1
    private let windowSize: Int
    private let accXML, accYML, accZML: MLMultiArray
    private let rotXML, rotYML, rotZML: MLMultiArray
    private let stateIn = Array(repeating: 0, count: 400)
    
    init(windowSize: Int) throws {
        self.windowSize = windowSize
        model = try StickingClassifier1(configuration: MLModelConfiguration())
        accXML = try multiArray(windowSize)
        accYML = try multiArray(windowSize)
        accZML = try multiArray(windowSize)
        rotXML = try multiArray(windowSize)
        rotYML = try multiArray(windowSize)
        rotZML = try multiArray(windowSize)
    }
    
    func classifySticking(from snapshot: [MovementData]) async -> Sticking? {
        for i in 0..<windowSize {
            let zero = NSNumber(value: 0.0)
            let isPadding = (i >= snapshot.count)
            accXML[i] = isPadding ? zero : NSNumber(value: snapshot[i].accX)
            accYML[i] = isPadding ? zero : NSNumber(value: snapshot[i].accY)
            accZML[i] = isPadding ? zero : NSNumber(value: snapshot[i].accZ)
            rotXML[i] = isPadding ? zero : NSNumber(value: snapshot[i].rotX)
            rotYML[i] = isPadding ? zero : NSNumber(value: snapshot[i].rotY)
            rotZML[i] = isPadding ? zero : NSNumber(value: snapshot[i].rotZ)
        }
        
        do {
            try Task.checkCancellation()
            
            let input = StickingClassifier1Input(
                accelerationX: accXML,
                accelerationY: accYML,
                accelerationZ: accZML,
                rotationRateX: rotXML,
                rotationRateY: rotYML,
                rotationRateZ: rotZML,
                stateIn: try MLMultiArray(stateIn)
            )
            
            // make prediction
            let prediction = try await model.prediction(input: input)
            print("\(prediction.label): \(String(describing: prediction.labelProbability[prediction.label]))")
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
