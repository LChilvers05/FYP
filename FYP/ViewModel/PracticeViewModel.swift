//
//  PracticeViewModel.swift
//  FYP
//
//  Created by Lee Chilvers on 26/01/2024.
//

import Foundation

final class PracticeViewModel {
    
    private let audioService = AudioService.shared
    private let onsetDetector = OnsetDetectionHandler()
    
    func beginPractice() {
        audioService.startListening()
    }
    
    func endPractice() {
        audioService.stopListening()
    }
}
