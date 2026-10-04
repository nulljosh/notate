# Notate loop handoff (2026-10-03, evening)

## What the loop is
One loop runs the App Store fix and ship work for the whole fleet, from this repo's seat because Notate is the next thing to build. It reads `~/.claude/projects/-Users-joshua/memory/project_asc_fix_loop_queue.md` (the LIVE PLAN at the top is the truth), does the next slice, updates that file and the `asc-status` skill, commits and pushes. The scheduled wakeups die with the session. The restart prompt at the bottom brings it back.

Always say Notate, never Voxprint. Charblock is Block Frame. Replies short, TLDR, no em dashes.

## Where things stand
- ASC: zero apps rejected. Waiting on Apple: Lexly iOS, Healstack iOS and macOS, Curbfind iOS, Madobe iOS and macOS, Windgate iOS and macOS, Sidewise iOS, Siftbox iOS and macOS, Plaintxt iOS, Charblock iOS 1.1.2, Notate iOS and macOS 1.4.1. Check with `python3 ~/.claude/skills/asc-status/scripts/status.py`. A red ! left on the dashboard is an old rejection message and clears on approval.
- Notate: 1.4.0 released, price $0.99 live, 1.4.1 submitted on both platforms (build 202610032040): new name, mic with sound bars icon, share button removed, listing text swept from Voxprint to Notate. The speech QA gate passed. Listing screenshots may still show the old name, check after approval.
- Plaintxt: a true reply is also on the App Review thread (f594a921). Apple's answer would show in `asc web review threads --app 6809841903`.
- Weekly usage was 89% at 20:45. Stop at 90 percent and report. The meter resets Sat 22:00.
- Internal disk was 7.5 GB free after cleanup. Keep above 6 GB before heavy jobs. Builds and DerivedData go on /Volumes/LaCie/lexly-qa. node_modules was removed in 13 repos (restore with `npm ci`).

## Next, in order
1. After the 22:00 reset (hook shows weekly_all below 50%): `asc-status` for new rejections or approvals and fix them with the recipe in `~/.claude/skills/asc-status/SKILL.md`.
2. Notate 1.4.2: bundle the tiny model at build time (offline first launch), pick the best model for the device in the background and swap between recordings, tiny as the fallback, extend `Tests/ModelRecoveryTests.swift`, keep the qa gate green (`TEST_RUNNER_VOXPRINT_QA=1 xcodebuild test -scheme VoxprintTests -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`). Never ship on "it builds".
3. Then a custom dictionary (Whisper prompt word list, test it does not blank output) and on-device AI cleanup with Apple Foundation Models. The keyboard is its own project, later.
4. Phase 2 fleet audit of ~/Documents/Code, read-only first, checks a to l are in the queue file. Make a `fleet-audit` skill with a script. Do not resubmit healthy live apps just for hygiene fixes.
5. Leftovers: Mac screenshots for Windgate, Siftbox and Notate are old. The Madobe stray empty draft submission 48cd5eec is harmless.

## Gotchas learned today
- Resubmit a rejected version with the same version string and a higher build number. Attach the build, resolve the rejected review item, then submit the old submission (the recipe is in the asc-status skill).
- asc web login: run `asc-login`. Joshua clicks Allow on Apple's dialog himself, never click it for him. The 2FA reader then reads the code off the screen. Wait 20 minutes between attempts.
- `asc xcode export` with the repo ExportOptions can upload straight to ASC and leave no local file. Check `asc builds list` before uploading again.
- xcodebuild test hangs on document-based app hosts (Plaintxt). Verify pure logic with swiftc instead. SwiftLint plugin validation needs `-skipPackagePluginValidation`.
- App Review replies and anything outward-facing need Joshua's yes in chat. Never run `sync`.
- Never launch visible apps or take full-screen screenshots, they can catch private tabs. Capture one window or use the simulator.

## Restart prompt
```
/loop Continue the App Store fix loop. Read ~/.claude/projects/-Users-joshua/memory/project_asc_fix_loop_queue.md. Only act if the weekly usage meter has reset (hook shows weekly_all below 50%) or Joshua has unblocked an item; then start Phase 2 (the fleet audit: read-only first, make a fleet-audit skill with a script) and check asc-status for new rejections or approvals. Otherwise do nothing and re-arm. Follow the queue rules. Stop and report at 90 percent weekly usage.
```
