//
//  Repository.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import AudioKit
import Foundation

final class Repository {
    
    func getRudiments() -> [Rudiment] {
        guard let url = getFileURL("rudiments", "json") else { return [] }
        
        var rudiments: [Rudiment] = []
        
        do {
            let data = try Data(contentsOf: url)
            rudiments = try JSONDecoder().decode([Rudiment].self, from: data)
            
        } catch {
            debugPrint(error)
        }
        
        return rudiments
    }
    
    func getRudimentMIDI(_ resource: String?) -> MIDIFile? {
        guard let url = getFileURL(resource, "mid") else { return nil }
        return MIDIFile(url: url)
    }
    
    func savePractice(_ results: [Feedback?]) {
        // TODO: save in some file or DB
        var printables: [Feedback] = []
        for result in results {
            guard let result else { break }
            printables.append(result)
        }
        print(printables)
    }
    
    func logGesture(snapshot: [MovementData]) {
        let features = [
            "Time Stamp",
            "Rotation Rate X",
            "Rotation Rate Y",
            "Rotation Rate Z",
            "Acceleration X",
            "Acceleration Y",
            "Acceleration Z"
        ]
        
        var contents = ""
        
        // write features
        let featuresRow = features.joined(separator: ",")
        contents.append(featuresRow + "\n")
        
        // write data
        for datum in snapshot {
            let row = "\(datum.timestamp),\(datum.rotX),\(datum.rotY),\(datum.rotZ),\(datum.accX),\(datum.accY),\(datum.accZ)"
            contents.append(row + "\n")
        }
        
        print(contents)
    }
    
    private func getFileURL(_ resource: String?, _ type: String?) -> URL? {
        return Bundle.main.url(forResource: resource, withExtension: type)
    }
}
