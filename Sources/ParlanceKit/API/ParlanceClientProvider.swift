import Foundation
import ParlanceSDK

// ---------------------------------------------------------------------------
// MARK: - Client factory
// ---------------------------------------------------------------------------
// Constructs a ParlanceClient from the Keychain-stored API key.
// Pass the result into AppState / call-sites that need a live client.

public enum ParlanceClientProvider {

    private static var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Returns a ready-to-use `ParlanceClient` if an API key is stored, or `nil`.
    public static func make() -> ParlanceClient? {
        guard let key = KeychainHelper.getAPIKey(), !key.isEmpty else { return nil }
        return ParlanceClient(
            apiKey: key,
            clientName: "xcode-extension/\(bundleVersion)"
        )
    }

    /// Returns a `ParlanceClient` for an explicit key (used in Settings test-connection flow).
    public static func make(apiKey: String) -> ParlanceClient {
        ParlanceClient(
            apiKey: apiKey,
            clientName: "xcode-extension/\(bundleVersion)"
        )
    }
}
