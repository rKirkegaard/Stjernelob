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
    /// Om en tur er i gang. Vi reagerer kun på tilladelsessvar, mens vi måler,
    /// så et tilladelsesskift udenfor en tur aldrig starter GPS.
    private var isTracking = false

    private(set) var distanceMeters: Double = 0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        // Vis det blå statusbånd, mens vi måler i baggrunden — turen er aldrig
        // skjult for barnet (jf. velbefindende-/sikkerhedsreglerne).
        locationManager.showsBackgroundLocationIndicator = true
    }

    func start() {
        distanceMeters = 0
        lastLocation = nil
        isTracking = true
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            startPedometer()
        case .notDetermined:
            // Spørg om tilladelse; vi starter selve målingen i
            // `locationManagerDidChangeAuthorization`, når svaret er kendt.
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

    /// Start GPS-måling. Slår baggrundsopdateringer til, så distancen ikke fryser
    /// ved låst skærm under turen — men kun når det rent faktisk er tilladt.
    /// `allowsBackgroundLocationUpdates = true` er en hård assertion, der crasher,
    /// hvis appen ikke er "backgroundable" (fx på simulator eller hvis "location"
    /// ikke er i UIBackgroundModes). Kaldes kun, når der er givet lokationstilladelse.
    private func beginLocationUpdates() {
        if Self.backgroundLocationAllowed {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        locationManager.startUpdatingLocation()
    }

    /// Om baggrundslokation er tilladt i dette miljø. Falsk på simulator (ikke
    /// understøttet) og hvis Info.plist ikke erklærer "location"-baggrundstilstand.
    private static var backgroundLocationAllowed: Bool {
        #if targetEnvironment(simulator)
            false
        #else
            let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
            return modes?.contains("location") ?? false
        #endif
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

    /// Reagér på tilladelsessvaret. Under en tur: start GPS, når der gives
    /// adgang, og fald tilbage til skridt-måling, hvis adgang nægtes — så
    /// distancen vises uanset valg, og turen aldrig afhænger af GPS.
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
}
