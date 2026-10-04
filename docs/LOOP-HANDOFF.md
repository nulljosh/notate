# Notate loop handoff (2026-10-04, morning)

## What the loop is
One loop runs the App Store fix and ship work for the whole fleet, from this repo's seat because Notate is the next thing to build. It reads `~/.claude/projects/-Users-joshua/memory/project_asc_fix_loop_queue.md` (the LIVE PLAN at the top is the truth), does the next slice, updates that file and the `asc-status` skill, commits and pushes. The scheduled wakeups die with the session. The restart prompt at the bottom brings it back.

Always say Notate, never Voxprint. Charblock is Block Frame. Replies short, TLDR, no em dashes.

## Where things stand
- ASC: zero apps rejected. Waiting on Apple: Lexly iOS, Healstack iOS and macOS, Curbfind iOS, Madobe iOS and macOS, Windgate iOS and macOS, Sidewise iOS, Siftbox iOS and macOS, Plaintxt iOS, Charblock iOS, Notate macOS 1.4.1. Check with `python3 ~/.claude/skills/asc-status/scripts/status.py`. A red ! left on the dashboard is an old rejection message and clears on approval.
- Notate: iOS 1.4.1 is released and the store name is Notate. Price $0.99. macOS 1.4.1 is still in review. 1.4.2 is finished on main (bundled tiny model, background upgrade, fallback to tiny, custom words, one-tap on-device cleanup, What's New 1.4.2, 5 QA tests pass, landing and docs refreshed). Ship it as 1.4.2 after the Mac 1.4.1 clears: bump MARKETING_VERSION and the build number in project.yml, run the speech QA gate, archive iOS and macOS, upload, set What's New, submit. The release needs `scripts/fetch-tiny-model.sh` to have run (it is a pre-build step; Release fails without the model).
- Siftbox is becoming **Pare** (pear icon, files in siftbox/design: light, dark and tinted, square, no alpha). "Pear" is taken. Do the rename AFTER Siftbox leaves review: probe with `asc apps rename --app 6811141466 --locale en-US --name Pare` (fallbacks Fig or Quince), set CFBundleDisplayName and CFBundleName to Pare, put the icon files in the asset catalog, rebuild and resubmit, then follow asc-name-creator step 6 for repo, docs and domain.
- Fleet audit (skill `fleet-audit`) first pass is done and fixed. Left, low risk, ships with each app's next release: stale What's New in epiphany, healstack, litigate, sparkjar; project.yml vs pbxproj version drift in 6 repos; curvely marketing URL empty; encryption flag in cadence, homeroom, nulljosh.github.io; nimble and nyc installed names differ from ASC names (live and approved, leave).
- Weekly usage reset at 22:00 Sat and was about 2% on Sun morning. Stop at 90 percent and report.
- Internal disk was 7.5 GB free after cleanup. Keep above 6 GB before heavy jobs. Builds and DerivedData go on /Volumes/LaCie/lexly-qa. node_modules was removed in 13 repos (restore with `npm ci`).

## Next, in order
1. `asc-status`: new rejections or approvals first. Fix a rejection with the recipe in `~/.claude/skills/asc-status/SKILL.md`.
2. When Notate macOS 1.4.1 is approved: ship Notate 1.4.2 (see above), then release it.
3. When Siftbox is approved or rejected: do the Pare rename and rebuild.
4. Re-run the fleet audit before the next release batch: `cd ~/Documents/Code && python3 ~/.claude/skills/fleet-audit/scripts/audit.py --asc`.
5. Mac screenshots for Windgate and Notate are old. They can only be replaced when the version is not in review.
6. Notate keyboard (dictate into any app) is its own project, later. Icon direction for Notate is still Joshua's call.

## Gotchas learned
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
