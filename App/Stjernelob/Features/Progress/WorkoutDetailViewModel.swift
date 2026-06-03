import Foundation
import Observation
import StjernelobCore

/// Tilstand for én turs detaljer, inkl. billedarkivet. Indlæser billeddata fra
/// fil-laget og tilføjer nye billeder (private og lokale som standard).
@MainActor
@Observable
final class WorkoutDetailViewModel {
    private let environment: AppEnvironment
    private let now: () -> Date

    private(set) var workout: CompletedWorkoutDTO
    /// Indlæste billeddata pr. billede-id (til visning).
    private(set) var imageData: [UUID: Data] = [:]

    init(workout: CompletedWorkoutDTO, environment: AppEnvironment, now: @escaping () -> Date = { Date() }) {
        self.workout = workout
        self.environment = environment
        self.now = now
    }

    func load() {
        for photo in workout.photos {
            imageData[photo.id] = environment.photoStore.loadData(named: photo.fileName)
        }
    }

    /// Gem et nyt billede til turen. Billedet lægger op til at fange stedet/
    /// oplevelsen — aldrig kroppen (afsnit 4.5).
    func addPhoto(data: Data) {
        guard let fileName = try? environment.photoStore.save(data) else { return }
        let photo = WorkoutPhotoDTO(id: UUID(), fileName: fileName, caption: nil, createdAt: now())
        try? environment.workoutRepository.addPhoto(photo, toWorkoutWithId: workout.id)
        reload()
    }

    private func reload() {
        if let updated = (try? environment.workoutRepository.all())?.first(where: { $0.id == workout.id }) {
            workout = updated
        }
        load()
    }
}
