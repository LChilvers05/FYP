//
//  ConnectivityService.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import WatchConnectivity

final class WatchConnectivityService: NSObject {
    
    private var session: WCSession?
    
    static let shared = WatchConnectivityService()
    private override init() {
        super.init()
        activateSession()
    }
    
    var didStartPlaying: (() -> Void)?
    var didStopPlaying: (() -> Void)?
    
    private func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // send message to phone
    func sendToPhone(_ message: [String: Any]) {
        guard let session,
              session.isReachable else { return }
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message to iPhone")
        }
    }
    
    // receive phone messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        guard let isPlaying = message["is_playing"] as? Bool else { return }
        if isPlaying {
            didStartPlaying?()
        } else {
            didStopPlaying?()
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated")
    }
}
