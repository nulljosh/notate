# Directory listings

Name: Voxprint
One-liner: Speech to text that never leaves your device.
Description: Voxprint runs WhisperKit locally on iPhone and Mac, so audio is transcribed on-device with no cloud call, no account, and nothing uploaded. It transcribes live from the mic in real time or from a dropped-in file, auto-detecting across 12 languages.
Category: Productivity / Privacy / Developer Tools
Links: https://voxprint.heyitsmejosh.com · https://apps.apple.com/app/id6782604262 · https://github.com/nulljosh/voxprint

## AlternativeTo
List as an alternative to cloud dictation apps (Otter.ai, Aiko). Lead with "on-device, no cloud" as the differentiator. Use the one-liner and description above.

## Indie Hackers (Products)
Use the one-liner and description above. Indie Hackers rewards a real founder story in the comments, reuse the maker story from `launch/producthunt.md`'s first comment, don't paste it verbatim, keep it in first person as a product update instead of a launch announcement.

## BetaList
Skip. Voxprint is already public on the App Store and Product Hunt, BetaList is pre-launch only.

## Uneed
Use the one-liner and description above. Tag: Productivity, AI, Privacy.

## SaaSHub
List under Productivity > Transcription. Note the pricing model in the listing field exactly: free download, three free file transcriptions, then Voxprint Pro at $0.99 once, not a subscription.

## dev.to
Build-story angle, since the technical hook is real (on-device Whisper, not a wrapper around an API).

Title: How Voxprint keeps Whisper transcription fully on-device on iPhone and Mac

Draft outline:
- The problem: cloud dictation apps mean every recording passes through someone else's server before it becomes text.
- The core mechanic: `TranscriptionEngine` batches live audio in 2-second windows and only re-decodes the trailing ~8s each tick, so decode time stays flat as a recording grows instead of climbing with it.
- Model handling: WhisperKit's default cache directory is purgeable by iOS under storage pressure, so after the first download Voxprint copies the model into Application Support, which iOS won't purge, so later launches load instantly.
- Model selection is automatic based on device RAM, no picker, because the right model is a device fact, not a preference.
- Close with pricing: live dictation free and unlimited, file transcription free for three files then $0.99 once, and a link to the GitHub repo since the code is open.
