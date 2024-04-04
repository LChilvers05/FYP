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
    private var stickingClassifier: StickingClassifierHandler?
    
    var didReceiveStroke: ((UserStroke) -> Void)?
    
    func set(_ didReceiveStroke: ((UserStroke) -> Void)?) {
        self.didReceiveStroke = didReceiveStroke
        // predict sticking with stroke motion from watch
        connectivityService.didReceiveStroke = { stroke in
            Task {
                guard let motion = stroke.motion,
                      let sticking = await self.stickingClassifier?.predict(motion)
                else { return }
                
                self.log(motion)
                
                var stroke = stroke
                stroke.sticking = sticking
                stroke.motion = nil
                
                self.didReceiveStroke?(stroke)
            }
        }
    }
}

// watch communication
extension Repository {
    
    func didStartPlaying(_ isPlaying: Bool) {
        do { // init new sticking classifier
            if isPlaying { stickingClassifier = try StickingClassifierHandler() }
            connectivityService.sendToWatch(["is_playing": isPlaying])
        } catch {
            debugPrint(error.localizedDescription)
        }
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
//        print(log)
    }
    
    func log(_ motion: [MotionData]) {
        let features = [
            "timestamp",
            "rotationRateX",
            "rotationRateY",
            "rotationRateZ",
            "accelerationX",
            "accelerationY",
            "accelerationZ"
        ]
        
        var contents = ""
        
        // write features
        let featuresRow = features.joined(separator: ",")
        contents.append(featuresRow + "\n")
        
        // write data
        for datum in motion {
            let row = "\(datum.timestamp),\(datum.rotationX),\(datum.rotationY),\(datum.rotationZ),\(datum.accelerationX),\(datum.accelerationY),\(datum.accelerationZ)"
            contents.append(row + "\n")
        }
        // to train CoreML model with
//        print(contents)
    }
}
