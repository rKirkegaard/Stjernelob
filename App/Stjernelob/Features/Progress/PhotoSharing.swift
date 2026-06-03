import Foundation
import UIKit

/// Forbereder et billede til deling ved at fjerne EXIF/lokationsmetadata
/// (afsnit 14.2): et delt billede må aldrig røbe, hvor brugeren bor eller løber.
/// Re-encodning som JPEG dropper den oprindelige metadata, inkl. GPS.
enum PhotoSharing {
    static func strippedJPEG(from data: Data, quality: CGFloat = 0.9) -> Data? {
        UIImage(data: data)?.jpegData(compressionQuality: quality)
    }

    /// Skriv et renset billede til en midlertidig fil, der kan deles via ShareLink.
    static func temporaryStrippedFile(from data: Data) -> URL? {
        guard let stripped = strippedJPEG(from: data) else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stjernelob-foto-\(UUID().uuidString).jpg")
        do {
            try stripped.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
