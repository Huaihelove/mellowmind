import Foundation
import CryptoKit
import Security

// MARK: - Module 3: Local encrypted wish sealing
// AES-GCM ciphertext is stored in SwiftData; the 256-bit key stays in Keychain rather than an ordinary file.

enum EncryptionError: LocalizedError {
    case keychain(OSStatus)
    case randomGenerationFailed
    case encodingFailed
    case invalidCiphertext
    case unreadableText

    var errorDescription: String? {
        switch self {
        case .keychain(let status):
            return "The local sealing key is unavailable (\(status))."
        case .randomGenerationFailed:
            return "A local sealing key could not be created."
        case .encodingFailed:
            return "The wish cannot be sealed right now."
        case .invalidCiphertext:
            return "The sealed content cannot be read and may have been cleared."
        case .unreadableText:
            return "The sealed content cannot be restored right now."
        }
    }
}

final class EncryptionService {
    static let shared = EncryptionService()

    private let service = "com.mellowmind.wishseal"
    private let account = "aes-gcm-256"
    private var cachedKey: SymmetricKey?

    private init() {}

    func encrypt(_ text: String) throws -> Data {
        guard let data = text.data(using: .utf8) else {
            throw EncryptionError.encodingFailed
        }
        let sealed = try AES.GCM.seal(data, using: try symmetricKey())
        guard let combined = sealed.combined else {
            throw EncryptionError.encodingFailed
        }
        return combined
    }

    func decrypt(_ data: Data) throws -> String {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            let clear = try AES.GCM.open(box, using: try symmetricKey())
            guard let text = String(data: clear, encoding: .utf8) else {
                throw EncryptionError.unreadableText
            }
            return text
        } catch let error as EncryptionError {
            throw error
        } catch {
            throw EncryptionError.invalidCiphertext
        }
    }

    func deleteKey() {
        cachedKey = nil
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func symmetricKey() throws -> SymmetricKey {
        if let cachedKey {
            return cachedKey
        }

        let lookup: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(lookup as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            let key = SymmetricKey(data: data)
            cachedKey = key
            return key
        }
        if status != errSecItemNotFound {
            throw EncryptionError.keychain(status)
        }

        var bytes = [UInt8](repeating: 0, count: 32)
        let randomStatus = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard randomStatus == errSecSuccess else {
            throw EncryptionError.randomGenerationFailed
        }
        let keyData = Data(bytes)
        let add: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let addStatus = SecItemAdd(add as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw EncryptionError.keychain(addStatus)
        }
        let key = SymmetricKey(data: keyData)
        cachedKey = key
        return key
    }
}