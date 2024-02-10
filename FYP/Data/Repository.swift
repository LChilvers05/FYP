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
            let row = "\(datum.time),\(datum.acceleration.x),\(datum.acceleration.y),\(datum.acceleration.z),\(datum.rotation.x),\(datum.rotation.y),\(datum.rotation.z)"
            contents.append(row + "\n")
        }
        
        writeToCSV(contents, path: "")
    }
    
    func writeToCSV(_ contents: String, path: String) {
        
        let fileManager = FileManager.default
        do {
            //TODO: 
//            let directory = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
//            let fileURL = directory.appendingPathComponent(path)
//            try contents.write(toFile: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing to CSV file: \(error.localizedDescription)")
        }
    }
    
    private func getFileURL(_ resource: String?, _ type: String?) -> URL? {
        return Bundle.main.url(forResource: resource, withExtension: type)
    }
}
