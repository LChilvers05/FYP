//
//  Repository.swift
//  FYP
//
//  Created by Lee Chilvers on 17/01/2024.
//

import AudioKit
import Foundation

final class Repository {
    
    // to fetch for the menu view
    func getRudiments() -> [Rudiment] {
        guard let url = getFileURL("rudiments", "json") else { return [] }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // TODO: let rudiments = decode without Rudiments list object
        } catch {
            
        }
        
        return []
    }
    
    // to featch in the detail view
    func getRudimentMIDI(_ resource: String?) -> MIDIFile? {
        guard let url = getFileURL(resource, "mid") else { return nil }
        return MIDIFile(url: url)
    }
    
    private func getFileURL(_ resource: String?, _ type: String?) -> URL? {
        return Bundle.main.url(forResource: resource, withExtension: type)
    }
}
