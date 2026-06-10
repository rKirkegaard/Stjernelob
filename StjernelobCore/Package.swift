// swift-tools-version:5.9
import PackageDescription

/// StjernelobCore — rent domænelag (ingen UI, ingen Apple-only frameworks).
///
/// Pakken bruger udelukkende Swift-standardbiblioteket og Foundation, så den
/// kan bygges og unit-testes på alle Swift-platforme (også Windows/Linux), ikke
/// kun på en Mac. Den indeholder den sikkerhedskritiske intervalmotor,
/// programprogressionen, streak/ugemål-logikken og point/stjerner/niveauer.
///
/// Se docs/specifikation.md og .claude/rules/arkitektur.md.
let package = Package(
    name: "StjernelobCore",
    // `Duration` kræver disse minimumsversioner. Uden erklæringen antager SPM en
    // for gammel platform på Apple-mål, og koden fejler ved kompilering (men ikke
    // på Windows, hvor tilgængelighed ikke gates) — derfor sættes de eksplicit.
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "StjernelobCore", targets: ["StjernelobCore"]),
    ],
    targets: [
        .target(
            name: "StjernelobCore"
        ),
        .testTarget(
            name: "StjernelobCoreTests",
            dependencies: ["StjernelobCore"]
        ),
    ]
)
