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
    private let accelerationX, accelerationY, accelerationZ: MLMultiArray
    private let rotationX, rotationY, rotationZ: MLMultiArray
    private let stateIn = Array(repeating: 0, count: 400)
    
    init(_ windowSize: Int) throws {
        self.windowSize = windowSize
        
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all // use CPU, GPU, Neural Engine
        model = try StickingClassifier9(configuration: configuration)
        
        accelerationX = try multiArray(windowSize)
        accelerationY = try multiArray(windowSize)
        accelerationZ = try multiArray(windowSize)
        rotationX = try multiArray(windowSize)
        rotationY = try multiArray(windowSize)
        rotationZ = try multiArray(windowSize)
    }
    
    func predict(_ motion: [MotionData]) async -> Sticking? {
        guard motion.count == windowSize else { return nil }
        for i in 0..<windowSize {
            accelerationX[i] = NSNumber(value: motion[i].accelerationX)
            accelerationY[i] = NSNumber(value: motion[i].accelerationY)
            accelerationZ[i] = NSNumber(value: motion[i].accelerationZ)
            rotationX[i] = NSNumber(value: motion[i].rotationX)
            rotationY[i] = NSNumber(value: motion[i].rotationY)
            rotationZ[i] = NSNumber(value: motion[i].rotationZ)
        }
        
        do {
            try Task.checkCancellation()
            
            let input = StickingClassifier9Input(
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
                rotationRateX: rotationX,
                rotationRateY: rotationY,
                rotationRateZ: rotationZ,
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
