import StjernelobCore
import SwiftUI

/// Ét muligt startpunkt i forløbet: en uge vist med dens løb/gå-mønster, så man
/// kan vælge det niveau, der føles rigtigt (fx "løb 20s / gå 90s").
struct StartingPointOption: Identifiable {
    let weekIndex: Int // 0-baseret indeks i forløbet
    let weekId: Int // 1-baseret visningsnummer
    let run: Duration
    let walk: Duration
    var id: Int { weekIndex }
}

/// Udleder de mulige startpunkter fra det indbyggede forløb. Mønsteret tages fra
/// ugens egen tur (uskaleret), så det beskriver niveauet — ikke dagens intensitet.
enum StartingPoints {
    static func options(sessionsPerWeek: Int = 3) -> [StartingPointOption] {
        StandardProgram.journey.weeks.enumerated().map { index, week in
            let intervals = week.plan(forSessionsPerWeek: sessionsPerWeek).intervals
            return StartingPointOption(
                weekIndex: index,
                weekId: week.id,
                run: intervals.first { $0.kind == .run }?.duration ?? .zero,
                walk: intervals.first { $0.kind == .walk }?.duration ?? .zero
            )
        }
    }
}

/// Delt vælger: vælg hvor i forløbet man vil starte (eller hoppe hen til).
/// Bruges både i onboarding og i indstillinger.
struct StartingPointView: View {
    @Binding var selectedWeekIndex: Int
    private let options = StartingPoints.options()

    var body: some View {
        List {
            Section {
                ForEach(options) { option in
                    row(option)
                }
            } footer: {
                Text(Strings.StartingPoint.note)
            }
        }
        .navigationTitle(Text(Strings.StartingPoint.title))
    }

    private func row(_ option: StartingPointOption) -> some View {
        Button {
            selectedWeekIndex = option.weekIndex
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.StartingPoint.week(option.weekId))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(Strings.StartingPoint.runWalk(
                        run: clock(option.run),
                        walk: clock(option.walk)
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                if option.weekIndex == selectedWeekIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.Colors.brand)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(option
            .weekIndex == selectedWeekIndex ? [.isSelected, .isButton] : .isButton)
    }

    /// Kompakt mm:ss uden enheds-ord (undgår hardcodet tekst).
    private func clock(_ duration: Duration) -> String {
        let seconds = Int(duration.components.seconds)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
