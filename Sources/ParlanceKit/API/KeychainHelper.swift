import Foundation
import Security

public enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .itemNotFound: return "API key not found in Keychain"
        case .duplicateItem: return "Duplicate item in Keychain"
        case .unexpectedStatus(let status): return "Keychain error: \(status)"
        }
    }
}

public enum KeychainHelper {
    private static let service = "business.parlance.xcode"
    private static let account = "api-key"
    private static let projectAccount = "selected-project-id"

    public static func saveSelectedProjectId(_ id: String) {
        let data = id.data(using: .utf8) ?? Data()
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: projectAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: projectAccount,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    public static func getSelectedProjectId() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: projectAccount,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let id = String(data: data, encoding: .utf8) else { return nil }
        return id
    }

    public static func saveAPIKey(_ key: String) throws {
        guard let data = key.data(using: .utf8) else { return }

        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    public static func getAPIKey() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }

    public static func deleteAPIKey() throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
