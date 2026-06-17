import StjernelobShared
import SwiftUI
import WidgetKit

/// Home Screen-widget med en blid, evig påmindelse (spec afsnit 10). Viser
/// bevidst ingen pres-tal — bare en venlig opfordring og, hvis der er data, en
/// kort beskrivelse af næste tur og en varm stime. Data læses fra en App Group,
/// som appen opdaterer (`WidgetSharedStore`).
struct NextRunEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct NextRunProvider: TimelineProvider {
    func placeholder(in _: Context) -> NextRunEntry {
        NextRunEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in _: Context, completion: @escaping (NextRunEntry) -> Void) {
        completion(NextRunEntry(date: .now, snapshot: WidgetSharedStore.load()))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<NextRunEntry>) -> Void) {
        let entry = NextRunEntry(date: .now, snapshot: WidgetSharedStore.load())
        // Appen genindlæser selv ved ændringer; en daglig opdatering holder det friskt.
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct NextRunWidgetView: View {
    var entry: NextRunEntry

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "figure.run")
                .font(.title)
                .foregroundStyle(.tint)
            Text(LocalizedStringResource("widget.nextRun", defaultValue: "Klar til en lille tur?"))
                .font(.caption)
                .multilineTextAlignment(.center)
            if let detail = entry.snapshot?.nextRunDetail, !detail.isEmpty {
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let weeks = entry.snapshot?.streakWeeks, weeks > 0 {
                Text(LocalizedStringResource(
                    "widget.streak",
                    defaultValue: "🌟 \(weeks) ugers stime"
                ))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tint)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct NextRunWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextRunWidget", provider: NextRunProvider()) { entry in
            NextRunWidgetView(entry: entry)
        }
        .configurationDisplayName(Text(LocalizedStringResource(
            "widget.displayName",
            defaultValue: "Stjerneløb"
        )))
        .description(Text(LocalizedStringResource(
            "widget.description",
            defaultValue: "En blid påmindelse om din næste tur."
        )))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
