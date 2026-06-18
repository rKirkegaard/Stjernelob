import Foundation
import Observation
import StjernelobCore
import StjernelobShared
import WidgetKit

/// Appens afhængigheds-container. Samler de tjenester, som ViewModels og views
/// får injiceret (jf. `arkitektur.md`: afhængigheder injiceres, ingen skjulte
/// singletons). Vokser efterhånden som lyd/haptik, synk og sikkerhed kommer til.
@MainActor
@Observable
final class AppEnvironment {
    /// Monotont ur til intervalmotoren — udskifteligt i test/preview.
    let clock: any MonotonicClock

    /// Lokal datalagring (kilden til sandhed, offline-først).
    let store: SwiftDataStore

    /// Billedfiler på disk (med Data Protection).
    let photoStore: any PhotoStore

    /// Brugerens indstillinger (lyd/stemme/haptik, påmindelser, streak-fryser).
    let settings: SettingsStore

    /// Planlægger venlige lokale påmindelser.
    let notificationScheduler = NotificationScheduler()

    /// HealthKit (valgfrit, med samtykke).
    let healthKit = HealthKitService()

    /// Position til personlig sikkerhed (opt-in).
    let locationService = LocationService()

    /// Gemmer en igangværende tur, så den kan genoptages efter app-luk.
    let runStateStore = RunStateStore()

    /// WatchConnectivity (telefon-side). Aktiveres ved appstart.
    @ObservationIgnored private var phoneSync: PhoneSyncService?

    /// Aktivér ur-synk (kald én gang ved appstart).
    func activateWatchSync() {
        guard phoneSync == nil else { return }
        phoneSync = PhoneSyncService(environment: self)
    }

    /// Send den aktuelle uges tur til uret.
    func sendCurrentSessionToWatch() {
        phoneSync?.sendCurrentSession()
    }

    /// Opdatér det delte widget-øjebliksbillede (næste tur + stime) og bed
    /// WidgetKit genindlæse. Kaldes ved appstart og når data ændrer sig.
    func refreshWidget() {
        WidgetUpdater(environment: self).refresh()
    }

    /// Planlæg venlige påmindelser på brugerens valgte træningsdage (eller det
    /// automatiske forslag, hvis ingen er valgt). Kaldes når dage/påmindelser
    /// ændres, så reminders altid matcher den aktuelle plan.
    func rescheduleReminders() async {
        let profile = try? profileRepository.load()
        let sessions = profile?.defaultWeeklySessions ?? 3
        let days = WeekScheduler.resolvedTrainingDays(
            chosen: profile?.trainingDays ?? [],
            sessionsPerWeek: sessions
        )
        await notificationScheduler.reschedule(
            enabled: settings.remindersEnabled,
            hour: settings.reminderHour,
            mondayBasedDays: days
        )
    }

    init(
        clock: any MonotonicClock = SystemMonotonicClock(),
        store: SwiftDataStore? = nil,
        photoStore: any PhotoStore = FilePhotoStore(),
        settings: SettingsStore? = nil
    ) {
        self.clock = clock
        // makeDefault() er @MainActor; kaldes her i init-kroppen (MainActor-
        // isoleret) frem for som default-argument (nonisolated kontekst).
        self.store = store ?? SwiftDataStore.makeDefault()
        self.photoStore = photoStore
        self.settings = settings ?? SettingsStore()
    }

    /// Fuld datasletning (GDPR, afsnit 14): rydder lokal database, billedfiler og
    /// det delte widget-øjebliksbillede. Den lokale sletning forplanter sig til
    /// brugerens private CloudKit-database via SwiftDatas spejling.
    func eraseAllData() {
        try? store.eraseAllData()
        photoStore.deleteAll()
        WidgetSharedStore.clear()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Bekvemmelig in-memory-opsætning til previews.
    static var preview: AppEnvironment {
        AppEnvironment(clock: ManualClock(), store: .makeInMemory())
    }

    // Repository-adgang (SwiftDataStore opfylder alle protokoller).
    var profileRepository: any ProfileRepository { store }
    var workoutRepository: any WorkoutRepository { store }
    var weeklyPlanRepository: any WeeklyPlanRepository { store }
    var badgeRepository: any BadgeRepository { store }
    var planLibraryRepository: any PlanLibraryRepository { store }
    var dataEraser: any DataEraser { store }
}
