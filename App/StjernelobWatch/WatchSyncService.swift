import Foundation
import WatchConnectivity
import StjernelobCore

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

    func sendCompletion(_ payload: WatchCompletionPayload) {
        guard WCSession.isSupported() else { return }
        if let data = try? JSONEncoder().encode(payload) {
            WCSession.default.transferUserInfo(["completion": data])
        }
    }

    private func decodeSession(from context: [String: Any]) {
        guard let data = context["session"] as? Data,
              let payload = try? JSONDecoder().decode(WatchSessionPayload.self, from: data) else { return }
        latestSession = payload
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.decodeSession(from: applicationContext) }
    }
}
