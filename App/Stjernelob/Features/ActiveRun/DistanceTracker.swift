import CoreLocation
import CoreMotion
import Foundation

/// Måler distance under en tur via GPS (Core Location), med skridt/bevægelse
/// (Core Motion) som backup, fx på løbebånd eller hvis lokation er afslået
/// (spec afsnit 4.1/10). Distance og tempo vises neutralt og er aldrig
/// grundlag for belønning.
@MainActor
final class DistanceTracker: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let pedometer = CMPedometer()
    private var lastLocation: CLLocation?

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
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            startPedometer()
        default:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        pedometer.stopUpdates()
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

    nonisolated func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        // Distancefejl er ikke kritisk for turen — ignoreres.
    }
}
