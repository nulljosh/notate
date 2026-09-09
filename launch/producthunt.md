# Product Hunt

Name: Voxprint

Tagline (52): Speech to text that never leaves your device

Description (219): Whisper transcription that runs entirely on your iPhone or Mac. Live from the mic or from an audio file, in 12 languages. No account, no cloud, no subscription. Free for live dictation, one dollar to unlock files.

Topics: Productivity, Privacy, iOS

Pricing: Free. Voxprint Pro is a one-time $1 purchase that unlocks unlimited audio file transcription and the most accurate model. Not a subscription.

Links
Web: https://voxprint.heyitsmejosh.com
App Store: https://apps.apple.com/app/id6782604262
GitHub: https://github.com/nulljosh/voxprint

## First comment

Hi, I'm Josh, I built Voxprint.

I wanted dictation on my phone that I could trust with anything. Every app I tried sent the audio somewhere, asked for an account, or wanted eight dollars a month for what is really a model running on hardware I already own. So I put Whisper on the device itself.

Voxprint runs WhisperKit locally on iPhone and Mac. Audio is decoded in two second windows as you speak, so words show up while you are still talking rather than after you stop. It picks a model that fits your device's memory, caches it somewhere iOS will not purge, and works on a plane or in a basement because there is no network call to make. Nothing you say is uploaded, ever. There is no sign-up and no tracking.

It handles more than voice. Drop in a podcast, a lecture, or a song and it writes out the words, with auto-detect across 12 languages.

Live microphone transcription is free with no limits. The one paid thing is Voxprint Pro, a single one dollar purchase that unlocks unlimited audio file transcription and the Small model, the most accurate one. You buy it once. I'd rather sell a tool than rent one.

The web app and the whole codebase are open. Happy to answer anything about the on-device pipeline.
