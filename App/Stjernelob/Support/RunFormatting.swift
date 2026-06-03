import Foundation

/// Formatering af distance og tempo. Tempo vises neutralt og lavt prioriteret —
/// det er aldrig noget, brugeren bedømmes eller belønnes på (spec afsnit 4.1).
enum RunFormatting {
    static func distance(meters: Double) -> String {
        String(format: "%.2f km", meters / 1000)
    }

    /// Tempo i min/km. Returnerer "–", indtil der er målt nok distance til et
    /// meningsfuldt tal.
    static func pace(elapsedSeconds: Double, meters: Double) -> String {
        guard meters > 50, elapsedSeconds > 0 else { return "–" }
        let secondsPerKm = elapsedSeconds / (meters / 1000)
        return String(format: "%d:%02d /km", Int(secondsPerKm) / 60, Int(secondsPerKm) % 60)
    }
}
