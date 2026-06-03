// swift-tools-version:5.9
import PackageDescription

// StjernelobCore — rent domænelag (ingen UI, ingen Apple-only frameworks).
//
// Pakken bruger udelukkende Swift-standardbiblioteket og Foundation, så den
// kan bygges og unit-testes på alle Swift-platforme (også Windows/Linux), ikke
// kun på en Mac. Den indeholder den sikkerhedskritiske intervalmotor,
// programprogressionen, streak/ugemål-logikken og point/stjerner/niveauer.
//
// Se docs/specifikation.md og .claude/rules/arkitektur.md.
let package = Package(
    name: "StjernelobCore",
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
