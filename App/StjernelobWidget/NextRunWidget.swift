import WidgetKit
import SwiftUI

/// Home Screen-widget med en blid, evig påmindelse (spec afsnit 10). Viser
/// bevidst ingen pres-tal — bare en venlig opfordring. Rigtige data (næste tur,
/// stime) kobles på via en App Group, når delt lagring sættes op.
struct NextRunEntry: TimelineEntry {
    let date: Date
}

struct NextRunProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextRunEntry { NextRunEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (NextRunEntry) -> Void) {
        completion(NextRunEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextRunEntry>) -> Void) {
        completion(Timeline(entries: [NextRunEntry(date: .now)], policy: .never))
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
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct NextRunWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextRunWidget", provider: NextRunProvider()) { entry in
            NextRunWidgetView(entry: entry)
        }
        .configurationDisplayName(Text(LocalizedStringResource("widget.displayName", defaultValue: "Stjerneløb")))
        .description(Text(LocalizedStringResource("widget.description", defaultValue: "En blid påmindelse om din næste tur.")))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
