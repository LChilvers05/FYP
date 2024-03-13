//
//  PhoneConnectivityService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import WatchConnectivity
import CoreMotion

final class PhoneConnectivityService: NSObject {
    
    @Published var stream: MovementData? = nil
    
    private var session: WCSession?
    
    static let shared = PhoneConnectivityService()
    private override init() {
        super.init()
        activateSession()
    }
    
    func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // send message to watch
    func sendToWatch(_ message: [String: Any]) {
        guard let session,
              session.isReachable else { return }
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message to Apple Watch \(error.localizedDescription)")
        }
    }
    
    // receive watch motion data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["movement"] as? Data else { return }
        do {
            let movement = try JSONDecoder().decode(MovementData.self, from: data)
            // update subscribers
            stream = movement
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension PhoneConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error { debugPrint(error) }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        guard WCSession.isSupported() else { return }
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch session inactive")
    }
}
