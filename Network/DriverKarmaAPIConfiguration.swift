import Foundation

/// Supplies per-request headers for authenticated DriverKarma endpoints.
/// The token source (Keychain, session store, ...) is injected so this class stays storage-agnostic.
final class DriverKarmaAPIConfiguration {
    private let accessTokenProvider: () -> String?

    init(accessTokenProvider: @escaping () -> String?) {
        self.accessTokenProvider = accessTokenProvider
    }

    func headers() -> [String: String] {
        var headers = ["Accept": "application/json"]
        if let token = accessTokenProvider(), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
