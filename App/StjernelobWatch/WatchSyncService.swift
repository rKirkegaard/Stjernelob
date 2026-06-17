import Foundation
import StjernelobCore
import WatchConnectivity

/// WatchConnectivity på ur-siden: modtager den aktuelle tur fra telefonen og
/// sender turens resultat tilbage, så det havner i historikken. Uret fungerer
/// stadig selvstændigt, hvis telefonen ikke er i nærheden.
@MainActor
final class WatchSyncService: NSObject, WCSessionDelegate {
    private(set) var latestSession: WatchSessionPayload?

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        // Brug en allerede modtaget kontekst, hvis den findes.
        decodeSession(from: WCSession.default.receivedApplicationContext)
    }

    /// Om telefonen er i nærheden og kan nås nu. Bruges til at afgøre, om uret
    /// skal måle sin egen GPS/distance (kun når telefonen ikke er med på turen).
    var isPhoneReachable: Bool {
        WCSession.isSupported()
            && WCSession.default.activationState == .activated
            && WCSession.default.isReachable
    }

    func sendCompletion(_ payload: WatchCompletionPayload) {
        guard WCSession.isSupported() else { return }
        if let data = try? JSONEncoder().encode(payload) {
            WCSession.default.transferUserInfo(["completion": data])
        }
    }

    private func decodeSession(from context: [String: Any]) {
        guard let data = context["session"] as? Data,
              let payload = try? JSONDecoder().decode(WatchSessionPayload.self, from: data)
        else { return }
        latestSession = payload
    }

    nonisolated func session(
        _: WCSession,
        activationDidCompleteWith _: WCSessionActivationState,
        error _: Error?
    ) {}

    nonisolated func session(
        _: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in self.decodeSession(from: applicationContext) }
    }
}
