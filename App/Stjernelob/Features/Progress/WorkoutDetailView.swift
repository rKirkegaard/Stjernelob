import PhotosUI
import StjernelobCore
import SwiftUI
import UIKit

/// Detaljer for én gennemført tur (spec afsnit 6.4 + 4.5): dato, trin i forløbet,
/// hvad hun lavede, hvordan det føltes, stjerner — og billedarkivet for turen.
struct WorkoutDetailView: View {
    @State var viewModel: WorkoutDetailViewModel
    @State private var pickerItem: PhotosPickerItem?

    private let photoColumns = [GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.small)]

    private var workout: CompletedWorkoutDTO { viewModel.workout }

    var body: some View {
        List {
            Section {
                row(Strings.Progress.durationLabel, value: workout.activeDuration.shortText)
                if let distance = workout.distanceMeters {
                    row(
                        Strings.Progress.distanceLabel,
                        value: RunFormatting.distance(meters: distance)
                    )
                }
                row(
                    Strings.Progress.intervalsLabel,
                    value: "\(workout.intervalsCompleted) / \(workout.plannedIntervalCount)"
                )
                row(Strings.Progress.starsLabel, value: "\(workout.starsEarned)")
                if let effort = workout.perceivedEffort {
                    row(Strings.Progress.effortLabel, value: "\(effort) / 10")
                }
                if let bodySignal = workout.bodySignal {
                    HStack {
                        Text(Strings.Progress.bodyLabel)
                        Spacer()
                        Label { Text(bodySignal.displayLabel) } icon: {
                            Image(systemName: bodySignal.symbolName)
                                .foregroundStyle(bodySignal.tint)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(Strings.Progress.weekLabel(workout.programWeekId))
            }

            if let reflection = workout.reflection, !reflection.isEmpty {
                Section {
                    Text(reflection)
                } header: {
                    Text(Strings.Progress.reflectionLabel)
                }
            }

            Section {
                if workout.photos.isEmpty {
                    Text(Strings.Progress.noPhotos).foregroundStyle(.secondary)
                } else {
                    LazyVGrid(columns: photoColumns, spacing: Theme.Spacing.small) {
                        ForEach(workout.photos) { photo in
                            photoThumbnail(photo)
                        }
                    }
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label { Text(Strings.Progress.addPhoto) } icon: { Image(systemName: "camera") }
                }
            } header: {
                Text(Strings.Progress.photosLabel)
            } footer: {
                Text(Strings.Progress.photoHint)
            }
        }
        .navigationTitle(Text(workout.date.formatted(date: .abbreviated, time: .shortened)))
        .onAppear { viewModel.load() }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task { @MainActor in
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    viewModel.addPhoto(data: data)
                }
                pickerItem = nil
            }
        }
    }

    @ViewBuilder
    private func photoThumbnail(_ photo: WorkoutPhotoDTO) -> some View {
        if let data = viewModel.imageData[photo.id], let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                .contextMenu {
                    if let url = PhotoSharing.temporaryStrippedFile(from: data) {
                        ShareLink(item: url) {
                            Label { Text(Strings.Progress.sharePhoto) } icon: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
        } else {
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 100, height: 100)
                .overlay { Image(systemName: "photo") }
        }
    }

    private func row(_ label: LocalizedStringResource, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).monospacedDigit().foregroundStyle(.secondary)
        }
    }
}
