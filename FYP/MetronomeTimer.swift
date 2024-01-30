//
//  Metronome.swift
//  FYP
//
//  Created by Lee Chilvers on 30/01/2024.
//

import Foundation

final class MetronomeTimer { //TODO: don't like name
    
    var value = 0.00
    private var timer: Timer?
    private let bar: Double
    
    init(bpm: Int, timeSignature: Int = 4) {
        let barInSeconds = Double(timeSignature)/(Double(bpm)/60.0)
        bar = round(barInSeconds * 100)/100
    }
    
    @objc private func fireTimer(timer: Timer) {
        // get value into a bar of music
        value += timer.timeInterval
        
        //TODO: reset externally when sequencer reaches end of bar?
        if value >= bar { value = 0.00 }
    }
    
    func start() {
        timer = Timer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(fireTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stop() {
        timer?.invalidate()
    }
}
