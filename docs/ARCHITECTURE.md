# Architecture

Voxprint is on-device speech transcription using WhisperKit. Record audio or drag a file; transcribe to text with live word-by-word updates. Offline-first (no network), models cached to Application Support after first download. iOS 17+ / macOS 14+, Universal Purchase. Renamed from Echo 2026-07-29 (App Store required single-word name).

## How it runs

`TranscriptionEngine.swift` manages WhisperKit model lifecycle: on first launch, downloads from HuggingFace to Caches (which iOS can purge), then copies to Application Support for persistence. Auto-selects model based on device RAM (Tiny for 2GB, Base for 4GB+). On record or file drop, `AudioCapture.swift` streams audio at 16kHz mono Float32. Every 2 seconds, engine batches audio, calls `WhisperKit.transcribe()`, and updates `transcriptionText` (Main thread). Live transcription only re-decodes a trailing ~8s window instead of the full rolling 30s buffer to avoid slowdown as recordings grow longer.

`ContentView.swift` (iOS/macOS shared, branches on `#if os(macOS)`) shows Record/File buttons at top, live transcript in the middle, bottom action bar (Copy / Share / Record/File input / History). Waveform visualization (`WaveformBarsView.swift`) responds to audio RMS in real-time. History holds max 50 entries (atomic JSON to UserDefaults). Settings picker lets users choose model and language (auto-detect + 11 languages); unusual language detection shows a badge if Whisper detects code not in the picker list.

## Files

| File | What it owns |
|---|---|
| `Sources/iOS/VoxprintApp.swift` | iOS app entry: window group, splash overlay, all-targets entry |
| `Sources/macOS/VoxprintApp.swift` | macOS app entry: window group with 1280x800 min size |
| `Sources/Models/TranscriptionEntry.swift` | Codable entry: id, text, date, duration (seconds), model name |
| `Sources/Services/TranscriptionEngine.swift` | WhisperKit model management: download/cache/load, transcribe, live update, language detection, model auto-selection by RAM |
| `Sources/Services/AudioCapture.swift` | AVAudioEngine tap: converts to 16kHz mono Float32, computes RMS for waveform, thread-safe via NSLock |
| `Sources/Views/ContentView.swift` | Main UI: record button, file drop (macOS), transcript display, action bar (copy/share/history), live waveform, settings icon (iOS) or gear (macOS) |
| `Sources/Views/RecordButton.swift` | Record/Stop button with state feedback |
| `Sources/Views/TranscriptionView.swift` | Live transcript display with language detection badge |
| `Sources/Views/WaveformBarsView.swift` | 5 animated bars responding to audio RMS in real-time |
| `Sources/Views/HistoryView.swift` | Past transcriptions: list, delete, share entry |
| `Sources/Views/SettingsView.swift` | Model picker (Auto/Tiny/Base/Small), language picker (auto + 11), status indicator |
| `Sources/iOS/Assets.xcassets/` | AppIcon (opaque PNG, no alpha; iOS 17+) |
| `Sources/macOS/Assets.xcassets/` | AppIcon set (16/32/64/128/256/512/1024, opaque, rounded corners baked in; macOS 14+) |
| `Sources/macOS/echo-mac.entitlements` | Sandbox entitlements: audio-input, network.client, files.user-selected.read-only |
| `web/index.html` | Landing page: inline style, no external CSS; responsive hero with screenshots, features, install links |
| `web/assets/icon.svg` | Icon: clean mic glyph on clrs.cc blue (#0074D9), geometric paths |
| `web/assets/screenshot-*.png` | App screenshots (fastlane-generated) |
| `project.yml` | XcodeGen: iOS/macOS targets, shared source tree, versions from MARKETING_VERSION/CURRENT_PROJECT_VERSION |
| `PrivacyInfo.xcprivacy` | Privacy manifest (bundled in both targets) |
| `watchos/` | watchOS companion app: shows transcription history and status from paired iPhone via App Group container |
| `watchos/VoxprintWatchApp.swift` | watchOS app entry point with window group |
| `watchos/ContentView.swift` | Main watchOS view: displays history, allows playback controls, syncs with iPhone |
| `watchos/Models/` | Data models mirroring iOS transcription entries for shared App Group storage |
| `watchos/Views/` | watchOS-specific UI components: history list, entry detail, playback controls |
| `watchos/Assets.xcassets/` | watchOS app icon and assets |
| `docs/index.html` | Redirects to app.html (kept for backward compatibility) |
| `docs/app.html` | Landing page: responsive hero, features list, app store links, install instructions, inline navigation and settings |
| `docs/styles.css` | Landing page styling: light/dark mode via prefers-color-scheme, responsive grid, device-frame screenshots |
| `docs/script.js` | Landing page interactivity: theme toggle, settings modal, feature carousel, smooth scrolling |
| `docs/devices.css` | Device frame styling for landing page demo screenshots (iPhone, Mac frames) |
| `docs/privacy.html` | Privacy policy page: static content, linked from landing footer |
| `UITests/PreviewScreenshot.swift` | Snapshot test suite: captures App Store screenshots in multiple locales and configurations |
| `UITests/SnapshotHelper.swift` | Fastlane snapshot helper: integrates with Xcode testing framework to generate screenshots |
| `UITests-mac/MacScreenshot.swift` | macOS App Store screenshot capture via UI automation |
| `Tests/TranscriptionEntryTests.swift` | Unit tests for TranscriptionEntry model (Codable, persistence) |
| `scripts/update_screenshots.sh` | Runs snapshot tests and stages generated screenshots for App Store upload |
| `ci_scripts/ci_post_clone.sh` | Xcode Cloud setup script: installs/runs xcodegen before building to regenerate xcodeproj from project.yml |

## Storage

- **UserDefaults**: settings (model, language, microphone permission), transcription history (max 50, atomic JSON)
- **Application Support**: WhisperKit models (persistent, survives iOS cache purge)
- **Caches**: initial HuggingFace download (transient, iOS can purge, triggers re-download and copy to Application Support)

## Audio pipeline

`AudioCapture` taps the input bus of AVAudioEngine at 44.1kHz, converts to 16kHz mono Float32 via AVAudioConverter, computes RMS per buffer for waveform visualization. Audio is buffered and passed to `TranscriptionEngine.transcribe()` in 2-second batches.

## Transcription pipeline

WhiskerKit max buffer is 30 seconds. Live transcription only processes a trailing ~8s window (not the full rolling 30s) to avoid slowdown as recordings grow longer. Batches are greedy-decoded (fastest, not most-accurate) to keep UI responsive. Language detection reads `DecodingResult.language` and `languageProbs` off the same call (no extra network).

## App Store gotchas

- Icon must be fully opaque (no alpha channel). Flatten with `magick icon.png -background '#0074D9' -alpha remove -alpha off PNG24:icon.png`.
- macOS icon needs separate 1024x1024 entry in Assets (universal 1024 alone is insufficient).
- `ITSAppUsesNonExemptEncryption=false` required in Info.plist to avoid manual ASC build-option confirmation on every upload.
- macOS requires `app-sandbox` entitlement for Mac App Store IAP.
- Screenshot display type is `APP_IPHONE_65` for 1284x2778 (not `IPHONE_67`).
- Versions live in `project.yml` only (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`); Info.plists reference these via `$(...)`, never hardcode.

## Gotchas

- Model download goes to Caches (iOS can purge). Copy to Application Support on first download for persistence.
- Fiber walk to find `liveFen()` is fragile to React version changes (not present in Voxprint, but pattern used elsewhere).
- Live transcription window at ~8s is calibrated for Whisper's 30s max and current device speeds. Recalibrate if models change or hardware baseline shifts.
- Unusual language badge visible only when language code not in picker's 11-item list.
