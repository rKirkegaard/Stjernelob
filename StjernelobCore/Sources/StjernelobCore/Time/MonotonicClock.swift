import Foundation

/// En monotont voksende urkilde.
///
/// Abstraktionen er nøglen til, at intervalmotoren er **deterministisk og
/// testbar**: i produktion bruges et ur baseret på systemets monotone klokke
/// (upåvirket af, at brugeren stiller uret), mens test bruger et `ManualClock`,
/// der skrues frem i hånden. Motoren beregner altid forløbet tid som en
/// *forskel* mellem to aflæsninger, så den ikke "driver" tidsmæssigt over en
/// lang tur (jf. `arkitektur.md` og `test.md`).
///
/// Tidspunkter udtrykkes som en `Duration` siden et vilkårligt, fast nulpunkt.
/// Kun forskelle mellem to aflæsninger er meningsfulde.
public protocol MonotonicClock: Sendable {
    func now() -> Duration
}

/// Produktionsur baseret på `ContinuousClock`, som er monotont og upåvirket af
/// ændringer i systemets vægur. Velegnet til en intervaltimer, der skal være
/// korrekt selv hvis uret stilles, sommertid skifter, eller appen er i
/// baggrunden.
public struct SystemMonotonicClock: MonotonicClock {
    private let clock = ContinuousClock()
    private let reference: ContinuousClock.Instant

    public init() {
        reference = ContinuousClock().now
    }

    public func now() -> Duration {
        reference.duration(to: clock.now)
    }
}

/// Manuelt ur til test og previews. Tiden bevæger sig kun, når den skrues frem
/// eksplicit — det gør det muligt at teste timing, rækkefølge, nedtælling og
/// afbrydelser uden at vente i realtid.
public final class ManualClock: MonotonicClock, @unchecked Sendable {
    private var current: Duration

    public init(_ start: Duration = .zero) {
        current = start
    }

    public func now() -> Duration {
        current
    }

    /// Skru uret frem med et tidsrum (skal være ikke-negativt for at forblive
    /// monotont).
    public func advance(by interval: Duration) {
        precondition(interval >= .zero, "Et monotont ur kan ikke gå baglæns")
        current += interval
    }

    /// Bekvemmelighed: skru frem i hele sekunder.
    public func advance(seconds: Double) {
        advance(by: .seconds(seconds))
    }
}
