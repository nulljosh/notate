# Voxprint (was Echo), CLAUDE.md

On-device Whisper transcription. iOS 17 + macOS 14, one unified ASC record (6782604262, Universal Purchase). WhisperKit via SPM. `roadmap.md` is the queue. `MONEY.md` is the price. `asc versions list --app 6782604262` is the truth on versions, never write them here.

## Frozen forever

Renamed Echo → Voxprint 2026-07-29. These keep the old name on purpose. Renaming any of them orphans existing installs:
`com.nulljosh.echo*` bundle IDs, `echo.*` UserDefaults keys, the `echo-models` model folder, `echo-history.json`.

## Money

No Pro, no IAP, no paywall code. Removed in 1.4.0. The app goes $0.99 upfront, but only flip the price AFTER 1.4.0 is approved: while 1.3.9 (free + $1 Pro) is the live build, a paid download would charge people twice. The old IAP `com.nulljosh.echo.unlock` still exists in ASC, unused.

## Structure

```
Sources/
  iOS/ macOS/   VoxprintApp.swift, Info.plist, Assets.xcassets (WhatsNewSheet is iOS)
  Models/       TranscriptionEntry
  Services/     TranscriptionEngine, AudioCapture, SpeechManager
  Views/        ContentView, RecordButton, TranscriptionView, WaveformBarsView,
                HistoryView, SettingsView, SplashView
Tests/          unit tests + ModelRecoveryTests (the end-to-end gate)
UITests/        fastlane snapshot screenshots
watchos/        standalone voice memo recorder, own xcodegen project
docs/           landing page + web demo (app.html)
```

**TranscriptionEngine** owns everything: model load, 2s live batches (8s trailing window, greedy), file transcription, history (max 50). Auto picks the model from device RAM.

**Model loading, read before touching it.** WhisperKit downloads into a cache iOS can purge, so the engine copies the model to `Application Support/echo-models/<model>` (temp name, then move, so a kill mid-copy cannot leave half a model). `cachedFolder` checks that stable folder by name first, because the absolute path stored in UserDefaults dies on every app update. If a load throws, every local copy is wiped and it tries once more clean. 1.3.9 shipped without this and bricked phones.

**SettingsView**: appearance, speak-back voice, language (own page, every Whisper language), status. The model picker is under Advanced on purpose. Users should not need it.

Accent color is the asset catalog blue. Buttons and splash use `Color.accentColor`, not `Color.primary`. Icon is the white mic on #0074D9.

## Build, test, ship

```bash
xcodegen generate            # no checked-in truth but project.yml
xcodebuild build -scheme Voxprint-macOS -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
TEST_RUNNER_VOXPRINT_QA=1 xcodebuild test -scheme VoxprintTests -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
asc workflow run ship-ios VERSION:x.y.z     # then ship-mac
```

The QA test plants a corrupt model, the engine must heal, then real `say` speech must transcribe. It is the first step of both ship workflows. Never remove it, never ship on "it builds".

Ship gotchas, all seen for real:
- The workflow's publish step fails on a new version: the build is still processing and the version record does not exist. Finish by hand: `asc versions create`, set whatsNew with `asc localizations update --id`, wait for the build to go VALID (`asc builds uploads list`), then `asc review submit --build-id`.
- App icon PNGs must have no alpha channel (error 90717). Flatten with `magick ... -background "#0074D9" -alpha remove -alpha off`.
- Versions live only in `project.yml`. Info.plists use `$(...)`.
- Do not edit Sources while an archive is running.

## Landing

`docs/` on Cloudflare Pages, project `voxprint`, domain voxprint.heyitsmejosh.com. A push deploys nothing:

```bash
npx wrangler pages deploy docs/ --project-name=voxprint --branch=main
```

## Notes

- `NSLock` guards `audioBuffer` (tap thread vs @MainActor)
- macOS drag-drop copies to temp (security scope). macOS has `app-sandbox`
- `PrivacyInfo.xcprivacy` in both targets, `ITSAppUsesNonExemptEncryption=false`
- DEVELOPMENT_TEAM: QMM486NPYC
- Icons: generate from `icon.svg`, never qlmanage
