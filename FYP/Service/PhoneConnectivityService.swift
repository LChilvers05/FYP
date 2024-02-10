//
//  PhoneConnectivityService.swift
//  FYP
//
//  Created by Lee Chilvers on 13/01/2024.
//

import WatchConnectivity
import CoreMotion

final class PhoneConnectivityService {
    
    @Published var stream: MovementData? = nil
    
    private var movement: MovementData? = nil
    private var session: WCSession?
    
    static let shared = PhoneConnectivityService()
    private init() {}
    
    func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // get watch motion data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let acceleration = message["acceleration"] as? CMAcceleration { handle(acceleration) }
        if let rotationRate = message["rotation_rate"] as? CMRotationRate { handle(rotationRate) }
    }
    
    // process acceleration data
    func handle(_ acceleration: CMAcceleration) {
        if movement == nil { movement = MovementData(time: 0.0) } // TODO: how to get time
        movement?.acceleration = acceleration
        handle(movement)
    }
    
    // process gyro data
    func handle(_ rotationRate: CMRotationRate) {
        if movement == nil { movement = MovementData(time: 0.0) }
        movement?.rotation = rotationRate
        handle(movement)
    }
    
    private func handle(_ movement: MovementData?) {
        guard movement?.acceleration != nil,
              movement?.rotation != nil else { return }
        // update subscribers
        stream = movement
        self.movement = nil
    }
    
    var description: String = ""
    var hash: Int = 0
    var superclass: AnyClass?
}

extension PhoneConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        guard WCSession.isSupported() else { return }
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch session inactive")
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
