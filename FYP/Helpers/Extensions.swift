//
//  Extensions.swift
//  FYP
//
//  Created by Lee Chilvers on 06/02/2024.
//

import AudioKit
import Foundation

extension MIDIFile {
    func getEventsOf(type: MIDIStatusType) -> [MIDIEvent]? {
        let events = self.tracks.first?.events
        return events?.enumerated().filter { index, event in
            index % 2 == 0 &&
            event.status?.type == type
        }.map { $0.element }
    }
}
