import XCTest
@testable import Voxprint_macOS

/// End-to-end QA: a corrupt model folder must heal itself, then real speech must transcribe.
/// Needs network (downloads the tiny model), so it is opt-in:
///   TEST_RUNNER_VOXPRINT_QA=1 xcodebuild test -scheme VoxprintTests -destination "platform=macOS" CODE_SIGNING_ALLOWED=NO
@MainActor
final class ModelRecoveryTests: XCTestCase {
    func testCorruptModelHealsThenTranscribes() async throws {
        try XCTSkipIf(ProcessInfo.processInfo.environment["VOXPRINT_QA"] == nil, "opt-in, needs network")
        let fm = FileManager.default
        let model = "openai_whisper-tiny"
        let stable = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("echo-models").appendingPathComponent(model)

        // The 1.3.9 brick: a half-copied model sitting at the stable path.
        try? fm.removeItem(at: stable)
        let junk = stable.appendingPathComponent("MelSpectrogram.mlmodelc")
        try fm.createDirectory(at: junk, withIntermediateDirectories: true)
        try Data("not a model".utf8).write(to: junk.appendingPathComponent("model.mil"))

        let engine = TranscriptionEngine()
        engine.selectedModel = model
        await engine.loadModel()
        XCTAssertEqual(engine.modelState, .ready, "engine should wipe the corrupt copy and recover")

        // Second engine = next launch. Must load from the healed stable copy.
        let relaunch = TranscriptionEngine()
        relaunch.selectedModel = model
        await relaunch.loadModel()
        XCTAssertEqual(relaunch.modelState, .ready)

        let wav = fm.temporaryDirectory.appendingPathComponent("voxprint-qa.wav")
        let say = Process()
        say.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        say.arguments = ["-o", wav.path, "--data-format=LEI16@16000", "Hello, this is a transcription test for the quality check."]
        try say.run()
        say.waitUntilExit()

        await relaunch.transcribeFile(url: wav)
        let text = relaunch.transcribedText.lowercased()
        XCTAssertTrue(text.contains("transcription"), "got: \(text)")
        XCTAssertEqual(relaunch.entries.first?.text.lowercased(), text, "history should record it")
        if let entry = relaunch.entries.first { relaunch.deleteEntry(entry) } // keep real history clean
    }

    /// 1.4.2: a broken copy of the chosen model must drop back to the bundled tiny model at once,
    /// not an error screen, and the broken copy must be gone so the next launch can re-fetch it.
    func testBrokenChosenModelFallsBackToBundledTiny() async throws {
        try XCTSkipIf(ProcessInfo.processInfo.environment["VOXPRINT_QA"] == nil, "opt-in")
        try XCTSkipIf(TranscriptionEngine.bundledTiny == nil, "tiny model not bundled (run scripts/fetch-tiny-model.sh)")
        let fm = FileManager.default
        let model = "openai_whisper-base"
        let stable = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("echo-models").appendingPathComponent(model)
        try? fm.removeItem(at: stable)
        let junk = stable.appendingPathComponent("AudioEncoder.mlmodelc")
        try fm.createDirectory(at: junk, withIntermediateDirectories: true)
        try Data("not a model".utf8).write(to: junk.appendingPathComponent("model.mil"))

        let engine = TranscriptionEngine()
        engine.selectedModel = model
        await engine.loadModel()
        engine.cancelUpgrade() // no need to fetch base in a test
        XCTAssertEqual(engine.modelState, .ready, "broken base must not leave an error screen")
        XCTAssertEqual(engine.activeModel, TranscriptionEngine.tinyModel, "should be running on the bundled tiny model")
        XCTAssertFalse(fm.fileExists(atPath: stable.path), "the broken copy must be deleted")
    }

    /// Custom words: clean prompt text, and a prompt must never blank real speech.
    func testCustomWordsPromptTextAndNoBlankOutput() async throws {
        XCTAssertNil(TranscriptionEngine.promptText(from: " , \n "))
        XCTAssertEqual(TranscriptionEngine.promptText(from: "Notate, LEC\nnotate, Jaybulb"), " Notate, LEC, Jaybulb.")
        try XCTSkipIf(ProcessInfo.processInfo.environment["VOXPRINT_QA"] == nil, "opt-in")
        try XCTSkipIf(TranscriptionEngine.bundledTiny == nil, "tiny model not bundled")
        let engine = TranscriptionEngine()
        engine.selectedModel = TranscriptionEngine.tinyModel
        let saved = engine.customWords
        engine.customWords = "Notate, Jaybulb, Healstack, LEC"
        defer { engine.customWords = saved }
        await engine.loadModel()
        let wav = FileManager.default.temporaryDirectory.appendingPathComponent("notate-words.wav")
        let say = Process()
        say.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        say.arguments = ["-o", wav.path, "--data-format=LEI16@16000", "Hello, this is a transcription test for the quality check."]
        try say.run(); say.waitUntilExit()
        await engine.transcribeFile(url: wav)
        XCTAssertTrue(engine.transcribedText.lowercased().contains("transcription"), "prompt must not blank the output, got: \(engine.transcribedText)")
        if let entry = engine.entries.first { engine.deleteEntry(entry) }
    }
}
