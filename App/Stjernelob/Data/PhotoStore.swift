import Foundation

/// Lagrer billedfiler på disk. Billeder gemmes som filer med iOS Data Protection
/// (krypteret når enheden er låst), og databasen holder kun en reference til
/// filnavnet (jf. arkitektur.md og afsnit 14.2). Private og lokale som standard.
protocol PhotoStore: Sendable {
    /// Gem billeddata og returnér det genererede filnavn.
    func save(_ data: Data) throws -> String
    func loadData(named fileName: String) -> Data?
    func delete(named fileName: String)
    /// Slet alle billedfiler (indgår i fuld datasletning, afsnit 14).
    func deleteAll()
}

/// Fil-baseret implementering med fuld Data Protection.
final class FilePhotoStore: PhotoStore {
    private let directory: URL

    init() {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )) ?? FileManager.default.temporaryDirectory
        directory = base.appendingPathComponent("WorkoutPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func save(_ data: Data) throws -> String {
        let fileName = UUID().uuidString + ".jpg"
        try data.write(to: directory.appendingPathComponent(fileName), options: [.atomic, .completeFileProtection])
        return fileName
    }

    func loadData(named fileName: String) -> Data? {
        try? Data(contentsOf: directory.appendingPathComponent(fileName))
    }

    func delete(named fileName: String) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(fileName))
    }

    func deleteAll() {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}
