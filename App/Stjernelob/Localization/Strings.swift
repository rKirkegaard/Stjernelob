import Foundation

/// Alle brugervendte tekster ét sted, som `LocalizedStringResource`.
///
/// Views refererer til `Strings.…` i stedet for at indeholde danske strenge
/// direkte (jf. `.claude/rules/swift-style.md`: ingen hardcodede strenge i
/// views). `defaultValue` er den danske kildetekst og bruges, indtil et
/// String Catalog tilføjes for flere sprog. Tonen følger velbefindende-reglerne:
/// varm, opmuntrende, aldrig skyld eller pres.
enum Strings {
    enum App {
        static let name = LocalizedStringResource("app.name", defaultValue: "Stjerneløb")
    }

    enum Dashboard {
        static let weeksRun = LocalizedStringResource("dashboard.weeksRun", defaultValue: "Ugens tur")
    }

    enum Interval {
        static let warmUp = LocalizedStringResource("interval.warmUp", defaultValue: "Opvarmning")
        static let run = LocalizedStringResource("interval.run", defaultValue: "Løb")
        static let walk = LocalizedStringResource("interval.walk", defaultValue: "Gå")
        static let coolDown = LocalizedStringResource("interval.coolDown", defaultValue: "Nedkøling")
    }

    /// Stemmecoachens replikker (afsnit 4.2). Varme, korte, opmuntrende — aldrig
    /// pres eller fart-fokus.
    enum Coaching {
        static func runStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource("coaching.runStart", defaultValue: "Løb nu i \(duration)")
        }
        static func walkStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource("coaching.walkStart", defaultValue: "Godt klaret — gå roligt i \(duration)")
        }
        static let warmUpStart = LocalizedStringResource(
            "coaching.warmUpStart", defaultValue: "Vi varmer op med en rask gåtur")
        static let coolDownStart = LocalizedStringResource(
            "coaching.coolDownStart", defaultValue: "Flot — så køler vi af med rolig gang")
        static let halfway = LocalizedStringResource(
            "coaching.halfway", defaultValue: "Du er halvvejs — flot!")
        static let finished = LocalizedStringResource(
            "coaching.finished", defaultValue: "Fantastisk — du gennemførte hele turen!")
        static let talkTest = LocalizedStringResource(
            "coaching.talkTest", defaultValue: "Husk: kan du ikke tale imens, så sæt lidt farten ned")
    }

    enum Units {
        /// "3 løbeintervaller · i alt 18 min"
        static func sessionSummary(runCount: Int, total: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "units.sessionSummary",
                defaultValue: "\(runCount) løbeintervaller · i alt \(total)"
            )
        }
    }
}
