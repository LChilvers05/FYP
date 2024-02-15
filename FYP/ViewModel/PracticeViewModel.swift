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
        gestureRecognition.didGetSticking = self.didGetSticking
    }
    
    func startPractice() {
        gestureRecognition.startRecognition()
        onsetDetection.startDetecting()
        metronome.start() // starts player
    }
    
    func endPractice() {
        gestureRecognition.endRecognition()
        onsetDetection.stopDetecting()
        metronome.stop() // stops player
    }
    
    private func didDetectOnset(_ ampData: AmplitudeData) {
        guard !metronome.isCountingIn else { return }
        let stroke = UserStroke(
            positionInBeats: metronome.positionInBeats,
            amplitude: ampData,
            timestamp: metronome.timeElapsed
        )
        // register sticking request
        gestureRecognition.enqueue(stroke)
        // do rhythm analysis
        player.score(stroke)
    }
    
    private func didGetSticking(for stroke: UserStroke) {
        player.updateSticking(stroke)
    }
}
