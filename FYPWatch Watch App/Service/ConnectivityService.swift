//
//  ConnectivityService.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import WatchConnectivity

final class ConnectivityService {
    
    private let session = WCSession.default
    
    func sendToPhone(_ message: [String: Any]) {
        guard session.isReachable else { return }
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message to iPhone")
        }
    }
}
