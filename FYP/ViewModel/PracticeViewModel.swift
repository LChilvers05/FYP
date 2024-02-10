//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AudioKit
import Combine
import Foundation
import CoreMotion

final class PracticeViewModel: ObservableObject {
    
    @Published var metronome: Metronome
    
    private lazy var onsetDetection = OnsetDetectionHandler()
    private lazy var gestureRecognition = GestureRecognitionHandler()
    private let player: RudimentPlayer
    private let tempo = 70
        
    init(_ rudiment: Rudiment) {
        player = RudimentPlayer(rudiment, tempo)
        metronome = Metronome(sequencer: player.sequencer)
        
        onsetDetection.didDetectOnset = self.didDetectOnset
    }
    
    func startPractice() {
        onsetDetection.beginDetecting()
        metronome.start()
    }
    
    func endPractice() {
        onsetDetection.stopDetecting()
        metronome.stop()
    }
    
    private func didDetectOnset(_ ampData: AmplitudeData) {
        guard !metronome.isCountingIn else { return }
// TODO:        let sticking = gesture.recognition.getSticking()
        let stroke = UserStroke(
            positionInBeats: metronome.positionInBeats,
            sticking: .right,
            amplitude: ampData
        )
        player.score(stroke)
    }
}
