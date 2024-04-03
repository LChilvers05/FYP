//
//  StickingClassifierHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 18/02/2024.
//

import CoreML

final class StickingClassifierHandler {
    
    private let model: StickingClassifier9
    private let windowSize: Int
    private let accXML, accYML, accZML: MLMultiArray
    private let rotXML, rotYML, rotZML: MLMultiArray
    private let stateIn = Array(repeating: 0, count: 400)
    
    init(_ windowSize: Int) throws {
        self.windowSize = windowSize
        model = try StickingClassifier9(configuration: MLModelConfiguration())
        accXML = try multiArray(windowSize)
        accYML = try multiArray(windowSize)
        accZML = try multiArray(windowSize)
        rotXML = try multiArray(windowSize)
        rotYML = try multiArray(windowSize)
        rotZML = try multiArray(windowSize)
    }
    
    func predict(_ snapshot: [MotionData]) async -> Sticking? {
        guard snapshot.count == windowSize else { return nil }
        for i in 0..<windowSize {
            accXML[i] = NSNumber(value: snapshot[i].acceleration.x)
            accYML[i] = NSNumber(value: snapshot[i].acceleration.y)
            accZML[i] = NSNumber(value: snapshot[i].acceleration.z)
            rotXML[i] = NSNumber(value: snapshot[i].rotation.x)
            rotYML[i] = NSNumber(value: snapshot[i].rotation.y)
            rotZML[i] = NSNumber(value: snapshot[i].rotation.z)
        }
        
        do {
            try Task.checkCancellation()
            
            let input = StickingClassifier9Input(
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
//            print("\(prediction.label): \(String(describing: prediction.labelProbability[prediction.label]))")
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
