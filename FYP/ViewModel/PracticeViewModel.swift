//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import AudioKit
import Combine

final class PracticeViewModel: ObservableObject {
    
    @Published var metronome: Metronome
    
    private lazy var onsetDetector = OnsetDetectionHandler()
    private let player: RudimentPlayer
    private let tempo = 50
        
    init(_ rudiment: Rudiment) {
        player = RudimentPlayer(rudiment, tempo)
        metronome = Metronome(sequencer: player.sequencer)
        
        onsetDetector.didDetectOnset = self.didDetectOnset
    }
    
    func startPractice() {
        onsetDetector.beginDetecting()
        metronome.start()
    }
    
    func endPractice() {
        onsetDetector.stopDetecting()
        metronome.stop()
    }
    
    private func didDetectOnset(_ ampData: AmplitudeData) {
        guard !metronome.isCountingIn else { return }
        
        let stroke = UserStroke(
            positionInBeats: metronome.positionInBeats - 0.02, //TODO: latency?
            sticking: .right,
            amplitude: ampData
        )
        player.compare(userStroke: stroke)
    }
}
