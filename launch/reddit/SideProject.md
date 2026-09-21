Note: no karma gate posted in the sub rules, but check current standing before posting. Public launch, App Store link fine.

Title: I built a transcription app that never sends audio anywhere

Body:
Every dictation app I tried sent my audio to a server, wanted an account, or charged eight dollars a month for a model that could just run on the phone I already own. So I put Whisper on the device itself.

Voxprint runs WhisperKit locally on iPhone and Mac. It decodes live audio in two second windows so words show up while you're still talking, not after you stop. It also handles files: drop in a podcast, a lecture, a song, and it writes out the words, auto-detecting across 12 languages. Nothing is uploaded, ever, and there's no sign-up.

Built with SwiftUI and WhisperKit (CoreML). Live mic transcription is free and unlimited. File transcription is free for the first three files, then $0.99 once to unlock the rest, no subscription.

Would love feedback, especially on accuracy across languages and where the live-decode latency still shows.

https://voxprint.heyitsmejosh.com
