import Foundation

/// Hvordan kroppen føltes efter en tur — grundlaget for blid
/// skadesforebyggelse (jf. velbefindende-reglerne: forklar normal ømhed vs.
/// advarselstegn, og opfordr til pause/voksen/læge ved smerter).
///
/// Bruges aldrig til vurdering, pres eller belønning — kun til at møde et
/// advarselstegn med omsorg.
public enum BodySignal: String, Codable, Sendable, CaseIterable, Identifiable {
    /// Alt føltes fint.
    case allGood
    /// Lidt øm "på den gode måde" — normal træningsømhed.
    case goodSore
    /// En specifik smerte ét bestemt sted — værd at passe på.
    case specificPain

    public var id: String { rawValue }

    /// Om appen blidt bør vise omsorgsvejledning (hvile, og tal med en voksen/læge
    /// hvis smerten varer ved). Kun ved en specifik smerte.
    public var needsCare: Bool { self == .specificPain }
}
