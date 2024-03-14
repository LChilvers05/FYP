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
    
    var didStartPlaying: ((Bool) -> Void)?
    var didPlayStroke: ((UserStroke) -> Void)?
    
    private func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // send message to phone
    func sendToPhone(_ message: [String: Any]) {
        guard let session else { return }
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send message to iPhone \(error.localizedDescription)")
            }
        } else {
            do {
                try session.updateApplicationContext(message)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // receive phone messages
    private func didReceive(_ message: [String: Any]) {
        // started rudiment practice
        if let isPlaying = message["is_playing"] as? Bool {
            didStartPlaying?(isPlaying)
            
        // user made stroke
        } else if let data = message["stroke"] as? Data {
            do {
                let stroke = try JSONDecoder().decode(UserStroke.self, from: data)
                didPlayStroke?(stroke)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        didReceive(message)
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        didReceive(applicationContext)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error { debugPrint(error) }
    }
}

