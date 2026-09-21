Note: "Show and Tell" flair required. Weekly self-promo thread is the safer route than a standalone post, check it's pinned before posting this. Public launch, App Store link fine.

Title: Show and Tell: on-device Whisper transcription with WhisperKit, no cloud call

Body:
Wanted dictation I could trust with anything personal, and every option either phoned home or wanted a subscription for a model that runs fine on-device. Built Voxprint around WhisperKit instead.

The interesting part for this sub: `TranscriptionEngine` batches live audio in 2-second windows and only re-decodes the trailing ~8s each tick instead of the full rolling 30s buffer, so decode time stays flat as a recording gets longer. Model is picked automatically from device RAM at launch, no picker. WhisperKit's default cache lives in the purgeable HuggingFace Caches dir, so after first download Voxprint copies the model into Application Support so iOS doesn't purge it and force a re-download.

SwiftUI, iOS 17+, WhisperKit via SPM. Live mic transcription is free and unlimited. File transcription is free for the first three files, then $0.99 once, no subscription.

Happy to talk through the CoreML/decoding side if anyone's building something similar.

https://apps.apple.com/app/id6782604262
