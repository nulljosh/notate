import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// One-tap tidy-up of a transcript with Apple's on-device model. Nothing leaves the device.
/// Only offered where the system model exists and is ready (Apple Intelligence on, iOS or macOS 26+).
enum Cleanup {
    static let instructions = """
        You tidy dictated text. Fix punctuation, capitalization and grammar, and remove filler words \
        like um, uh, and you know. Keep the speaker's own words, meaning and language. Do not add, \
        summarize or answer anything. Reply with only the cleaned text.
        """

    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) { return SystemLanguageModel.default.isAvailable }
        #endif
        return false
    }

    static func clean(_ text: String) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            let session = LanguageModelSession(instructions: instructions)
            let reply = try await session.respond(to: text)
            let cleaned = reply.content.trimmingCharacters(in: .whitespacesAndNewlines)
            // A blank or runaway answer is worse than the original. Keep what was said.
            guard !cleaned.isEmpty, cleaned.count < text.count * 2 + 40 else { return text }
            return cleaned
        }
        #endif
        return text
    }
}
