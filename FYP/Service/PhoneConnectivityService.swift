//
//  PhoneConnectivityService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import WatchConnectivity
import CoreMotion

final class PhoneConnectivityService: NSObject {
    
    private var session: WCSession?
    
    var didReceiveStroke: ((UserStroke) -> Void)?
    
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
        guard let session else { return }
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send message to Apple Watch \(error.localizedDescription)")
            }
        } else {
            do {
                try session.updateApplicationContext(message)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // receive watch motion data
    private func didReceive(_ message: [String: Any]) {
        guard let data = message["stroke"] as? Data else { return }
        do {
            let stroke = try JSONDecoder().decode(UserStroke.self, from: data)
            didReceiveStroke?(stroke)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension PhoneConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        didReceive(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        didReceive(applicationContext)
    }
    
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
