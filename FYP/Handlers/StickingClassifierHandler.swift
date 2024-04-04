//
//  StickingClassifierHandler.swift
//  FYP
//
//  Created by Lee Chilvers on 18/02/2024.
//

import CoreML

final class StickingClassifierHandler {
    
    private let model: StickingClassifier9
    private let windowSize = WINDOW_SIZE
    private let stateIn: MLMultiArray
    
    init() throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine // use CPU, Neural Engine
        model = try StickingClassifier9(configuration: configuration)
        stateIn = try MLMultiArray(Array(repeating: 0, count: 400))
    }
    
    func predict(_ motion: [MotionData]) async -> Sticking? {
        guard motion.count == windowSize else { return nil }
        
        do {
            let accelerationX = try multiArray(windowSize)
            let accelerationY = try multiArray(windowSize)
            let accelerationZ = try multiArray(windowSize)
            let rotationX = try multiArray(windowSize)
            let rotationY = try multiArray(windowSize)
            let rotationZ = try multiArray(windowSize)
            
            for i in 0..<windowSize {
                accelerationX[i] = NSNumber(value: motion[i].accelerationX)
                accelerationY[i] = NSNumber(value: motion[i].accelerationY)
                accelerationZ[i] = NSNumber(value: motion[i].accelerationZ)
                rotationX[i] = NSNumber(value: motion[i].rotationX)
                rotationY[i] = NSNumber(value: motion[i].rotationY)
                rotationZ[i] = NSNumber(value: motion[i].rotationZ)
            }
            
            try Task.checkCancellation()
            
            let input = StickingClassifier9Input(
                accelerationX: accelerationX,
                accelerationY: accelerationY,
                accelerationZ: accelerationZ,
                rotationRateX: rotationX,
                rotationRateY: rotationY,
                rotationRateZ: rotationZ,
                stateIn: stateIn
            )
            
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
