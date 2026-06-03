import SwiftUI
import StjernelobCore

/// Detaljer for én gennemført tur (spec afsnit 6.4): dato, trin i forløbet,
/// hvad hun lavede, hvordan det føltes, stjerner og billeder.
struct WorkoutDetailView: View {
    let workout: CompletedWorkoutDTO

    var body: some View {
        List {
            Section {
                row(Strings.Progress.durationLabel, value: workout.activeDuration.shortText)
                row(Strings.Progress.intervalsLabel, value: "\(workout.intervalsCompleted) / \(workout.plannedIntervalCount)")
                row(Strings.Progress.starsLabel, value: "\(workout.starsEarned)")
                if let effort = workout.perceivedEffort {
                    row(Strings.Progress.effortLabel, value: "\(effort) / 10")
                }
            } header: {
                Text(Strings.Progress.weekLabel(workout.programWeekId))
            }

            Section {
                if workout.photos.isEmpty {
                    Text(Strings.Progress.noPhotos)
                        .foregroundStyle(.secondary)
                } else {
                    // Billedindlæsning fra fil-laget tilføjes med billedarkivet.
                    ForEach(workout.photos) { photo in
                        Text(photo.caption ?? photo.fileName)
                    }
                }
            } header: {
                Text(Strings.Progress.photosLabel)
            }
        }
        .navigationTitle(Text(workout.date.formatted(date: .abbreviated, time: .shortened)))
    }

    private func row(_ label: LocalizedStringResource, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).monospacedDigit().foregroundStyle(.secondary)
        }
    }
}
