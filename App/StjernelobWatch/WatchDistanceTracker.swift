import CoreLocation
import CoreMotion
import Foundation

/// Måler distance på uret under en selvstændig tur (uden telefonen): GPS via
/// Core Location, med skridt/bevægelse (Core Motion) som backup, fx på løbebånd
/// eller uden GPS-fix. Startes kun, når telefonen ikke er med (se `WatchRunModel`),
/// så vi ikke dobbeltmåler. Distance vises neutralt og er aldrig grundlag for
/// belønning (jf. velbefindende-reglerne).
@MainActor
final class WatchDistanceTracker: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let pedometer = CMPedometer()
    private var lastLocation: CLLocation?
    private var isTracking = false

    private(set) var distanceMeters: Double = 0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
    }

    func start() {
        distanceMeters = 0
        lastLocation = nil
        isTracking = true
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            startPedometer()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            beginLocationUpdates()
        }
    }

    func stop() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        pedometer.stopUpdates()
    }

    /// Start GPS-måling med baggrundsopdateringer, så distancen måles videre, mens
    /// håndleddet er nede (sammen med en aktiv HKWorkoutSession).
    private func beginLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    private func startPedometer() {
        guard CMPedometer.isDistanceAvailable() else { return }
        pedometer.startUpdates(from: Date()) { [weak self] data, _ in
            guard let meters = data?.distance?.doubleValue else { return }
            Task { @MainActor in self?.distanceMeters = meters }
        }
    }

    nonisolated func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let updates = locations
        Task { @MainActor in self.accumulate(updates) }
    }

    private func accumulate(_ locations: [CLLocation]) {
        for location in locations
            where location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50
        {
            if let last = lastLocation {
                let delta = location.distance(from: last)
                if delta > 0 { distanceMeters += delta }
            }
            lastLocation = location
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard self.isTracking else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.beginLocationUpdates()
            case .denied, .restricted:
                self.startPedometer()
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // Distancefejl er ikke kritisk for turen — ignoreres.
    }
}
