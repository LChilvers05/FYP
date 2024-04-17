//
//  Repository.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import AudioKit
import Foundation

final class Repository {
    
    private let connectivityService = PhoneConnectivityService.shared
    
    var didReceiveStroke: ((UserStroke) -> Void)?
    
    func set(_ didReceiveStroke: ((UserStroke) -> Void)?) {
        // stroke with sticking received from watch
        self.didReceiveStroke = didReceiveStroke
        connectivityService.didReceiveStroke = self.didReceiveStroke
    }
}

// watch communication
extension Repository {
    
    func didStartPlaying(_ isPlaying: Bool) {
        var message: [String: Any] = ["is_playing": isPlaying]
        if isPlaying { message["start"] = Date() }
        connectivityService.sendToWatch(message)
    }
    
    func requestSticking(for stroke: UserStroke) {
        do {
            let strokeData = try JSONEncoder().encode(stroke)
            connectivityService.sendToWatch(["stroke": strokeData])
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

// rudiment files
extension Repository {
    
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
    
    func getRudimentMIDI(_ resource: String?) -> MIDIFile {
        guard let url = getFileURL(resource, "mid") else {
            fatalError("Failed to fetch rudiment MIDI file")
        }
        return MIDIFile(url: url)
    }
    
    func getRudimentViewRequest(_ resource: String?) -> URLRequest? {
        guard let url = getFileURL(resource, "html") else {
            print("Failed to fetch rudiment HTML file")
            return nil
        }
        return URLRequest(url: url)
    }
    
    private func getFileURL(_ resource: String?, _ type: String?) -> URL? {
        return Bundle.main.url(forResource: resource, withExtension: type)
    }
}

// logging
extension Repository {
    
    func log(_ feedback: [Annotation?], _ attempt: Int) {
        var log = "\(attempt)"
        for annotation in feedback {
            guard let annotation else { continue }
            log += ",\(annotation)"
        }
        print(log)
    }
}
