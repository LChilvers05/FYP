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
    @Published var isPlaying: Bool = false
    @Published var attemptUpdates: String = ""
    @Published var prevAttemptUpdates: String = ""
    @Published var tempo = 70
    
    let rudimentViewRequest: URLRequest?
    
    private let repository = Repository()
    private let jsBuilder = JavaScriptBuilder()
    private lazy var onsetDetection = OnsetDetectionHandler()
    private let gestureRecognition: GestureRecognitionHandler
    private let player: RudimentPlayer
    
    private var cancellables: Set<AnyCancellable> = []
        
    init(_ rudiment: Rudiment) {
        player = RudimentPlayer(rudiment, repository)
        metronome = Metronome(sequencer: player.sequencer)
        gestureRecognition = GestureRecognitionHandler(repository)
        rudimentViewRequest = repository.getRudimentViewRequest(rudiment.view)
        
        metronome.update(tempo)
        onsetDetection.didDetectOnset = self.didDetectOnset
        gestureRecognition.didGetSticking = self.didGetSticking
        
        Task {
            await player.feedback?.$annotations
                .sink { [weak self] feedback in
                    guard let self else { return }
                    // update rudiment view with JS
                    Task { await MainActor.run {
                        self.attemptUpdates = self.jsBuilder.build(from: feedback[1])
                        self.prevAttemptUpdates = self.jsBuilder.build(from: feedback[0])
                    }}
                }
                .store(in: &cancellables)
        }
    }
    
    func update(_ tempo: Int) {
        stopPractice()
        metronome.update(tempo)
    }
    
    func startStopTapped() {
        metronome.isPlaying ? stopPractice() : startPractice()
    }
    
    private func startPractice() {
        player.rewind()
        gestureRecognition.startRecognition()
        onsetDetection.startDetecting()
        metronome.start() // starts player
        isPlaying = true
    }
    
    private func stopPractice() {
        gestureRecognition.stopRecognition()
        onsetDetection.stopDetecting()
        metronome.stop() // stops player
        isPlaying = false
    }
    
    private func didDetectOnset(_ ampData: AmplitudeData) {
        guard isPlaying else { return }
        let stroke = UserStroke(
            positionInBeats: metronome.positionInBeats,
            amplitude: ampData,
            timestamp: metronome.timeElapsed
        )
        // register sticking request
        gestureRecognition.enqueue(stroke)
        // do rhythm analysis
        player.scoreRhythm(for: stroke)
    }
    
    private func didGetSticking(for stroke: UserStroke) {
        player.checkSticking(for: stroke)
    }
}
