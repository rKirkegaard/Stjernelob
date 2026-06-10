import CoreLocation
import Foundation

/// Indkapsler Core Location til de personlige sikkerhedsfunktioner (spec
/// afsnit 12): position under en tur (opt-in, slukkes ved turslut). Selve
/// delingen af positionen sker via et transportlag (CloudKit/besked), der
/// kobles på senere — denne service leverer kun positionen og tilladelsen.
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var lastLocation: CLLocation?
    private(set) var isSharing = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// Start positionsdeling for en tur (kaldes kun hvis brugeren har slået det til).
    func startSharing() {
        isSharing = true
        manager.startUpdatingLocation()
    }

    /// Stop — kaldes automatisk når turen slutter.
    func stopSharing() {
        isSharing = false
        manager.stopUpdatingLocation()
    }

    nonisolated func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let latest = locations.last
        Task { @MainActor in self.lastLocation = latest }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // Positionsfejl er ikke kritisk for selve turen — ignoreres her.
    }
}
