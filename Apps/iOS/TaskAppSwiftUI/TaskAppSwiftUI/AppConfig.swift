import Foundation

enum AppConfig {
    static var baseURL: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            assertionFailure("Missing API_BASE_URL in Info.plist. Inject via build settings or xcconfig.")
            return ""
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
