//
//  Feedback.swift
//  FYP
//
//  Created by Lee Chilvers on 10/03/2024.
//

import Foundation

// for real-time feedback
actor Feedback {
    
    @Published private(set) var annotations: [[Annotation?]] = []
    private(set) var ptr = -1
    private(set) var strokes: [RudimentStroke]
    // [UserStroke.id: (Expected Sticking, Feedback Index)]
    private var lookup: [Int: (Sticking, (Int, Int))] = [:]
    
    init(_ strokes: [RudimentStroke]) {
        self.strokes = strokes
    }
    
    func checkSticking(for userStroke: UserStroke) {
        guard let stroke = lookup[userStroke.id] else { return }
        if userStroke.sticking != stroke.0 {
            let i = stroke.1.0
            let j = stroke.1.1
            // mark sticking fault
            annotate(.sticking, at: i, j)
        }
        lookup.removeValue(forKey: userStroke.id)
    }
    
    func scoreRhythm(for userStroke: UserStroke,
                     i: Int, curr: Int) {
        var i = i
        if curr < 0 { i -= 1 }
        let curr = (curr + strokes.count) % strokes.count // wrap
        
        let stroke = strokes[curr]

        let rhythm = stroke.checkRhythm(for: userStroke.positionInBeats)
        switch rhythm {
        case .early:
            // feedback for previous stroke
            scoreRhythm(for: userStroke, i: i, curr: curr-1)
        case .nextEarly, .nextSuccess:
            // feedback for next stroke
            var next = curr + 1
            if next >= strokes.count { i += 1 }
            next = (next + strokes.count) % strokes.count
            let nextStroke = strokes[next]
            annotate(
                (rhythm == .nextEarly) ? .early : .success,
                at: i, next,
                id: userStroke.id,
                sticking: nextStroke.sticking
            )
        default: //.success, .late
            annotate(
                rhythm,
                at: i, curr,
                id: userStroke.id,
                sticking: stroke.sticking
            )
        }
    }
    
    // shift focus MIDI stroke
    func shift() {
        // check for missed strokes
        if ptr >= 0 && annotations[1][ptr] == nil {
            annotate(.missed, at: 1, ptr)
        }
        // next event
        ptr += 1
        // shift feedback results
        if ptr == strokes.count {
            ptr = 0
            // move along annotations attempts
            annotations[0] = annotations[1]
            annotations[1] = annotations[2]
            annotations[2] = Array(repeating: nil, count: strokes.count)
            
            // update pointers in sticking lookup
            for (id, value) in lookup {
                let i = value.1.0 - 1
                if i < 0 {
                    lookup.removeValue(forKey: id)
                    continue
                }
                lookup[id]?.1.0 = i
            }
        }
    }
    
    func clear() {
        ptr = -1
        lookup = [:]
        annotations = Array (
            repeating: Array(
                repeating: nil,
                count: strokes.count
            ),
            count: 3
        )
    }
    
    private func annotate(_ annotation: Annotation, 
                          at i: Int, _ j: Int,
                          id: Int? = nil, sticking: Sticking? = nil) {
        let i = max(i, 0)
        annotations[i][j] = annotation
        
        guard let id, let sticking else { return }
        // update lookup table for when sticking predicted
        lookup[id] = (sticking, (i, j))
    }
}
