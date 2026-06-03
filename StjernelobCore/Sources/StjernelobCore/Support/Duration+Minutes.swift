import Foundation

public extension Duration {
    /// Et tidsrum i minutter — programforløbet er beskrevet i minutter
    /// (jf. spec afsnit 6.1), så dette gør planerne læsbare.
    static func minutes(_ minutes: Double) -> Duration {
        .seconds(minutes * 60)
    }
}
