//
//  ConnectivityService.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import WatchConnectivity

final class WatchConnectivityService {
    
    private var session: WCSession?
    
    static let shared = WatchConnectivityService()
    private init() {
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
        guard let isPlaying = message["is_playing"] as? Bool else { return }
        if isPlaying {
            didStartPlaying?()
        } else {
            didStopPlaying?()
        }
    }
    
    var description: String = ""
    var hash: Int = 0
    var superclass: AnyClass?
}

extension WatchConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated")
    }
    
    func `self`() -> Self { return self }
    func isProxy() -> Bool { return true }
    func isEqual(_ object: Any?) -> Bool { return true }
    func isKind(of aClass: AnyClass) -> Bool { return true }
    func isMember(of aClass: AnyClass) -> Bool { return true }
    func conforms(to aProtocol: Protocol) -> Bool { return true }
    func responds(to aSelector: Selector!) -> Bool { return true }
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>? { return nil }
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>? { return nil}
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>? { return nil}
}
