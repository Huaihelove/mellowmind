import Foundation

// MARK: - Lightweight community safety
// This version is a local community: posts stay on the device, but it still provides length limits, gentle-language guidance, reporting, and hiding.

enum ContentValidationError: LocalizedError {
    case empty
    case tooLong(Int)
    case disrespectful

    var errorDescription: String? {
        switch self {
        case .empty:
            return "Write a little something before posting."
        case .tooLong(let limit):
            return "Please keep the post within \(limit) characters."
        case .disrespectful:
            return "Please express this more gently. This space does not accept attacks, humiliation, or harmful language."
        }
    }
}

enum ContentModerationService {
    static let wishLimit = 280
    static let commentLimit = 120

    private static let blockedTerms = [
        "kill yourself", "worthless", "idiot", "get lost", "trash", "I will hurt you"
    ]

    static func validateWish(_ text: String) throws -> String {
        try validate(text, limit: wishLimit)
    }

    static func validateComment(_ text: String) throws -> String {
        try validate(text, limit: commentLimit)
    }

    static func validateName(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "Star Friend" }
        guard trimmed.count <= 16 else {
            throw ContentValidationError.tooLong(16)
        }
        if blockedTerms.contains(where: { trimmed.localizedCaseInsensitiveContains($0) }) {
            throw ContentValidationError.disrespectful
        }
        return trimmed
    }

    private static func validate(_ text: String, limit: Int) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ContentValidationError.empty }
        guard trimmed.count <= limit else { throw ContentValidationError.tooLong(limit) }
        if blockedTerms.contains(where: { trimmed.localizedCaseInsensitiveContains($0) }) {
            throw ContentValidationError.disrespectful
        }
        return trimmed
    }
}