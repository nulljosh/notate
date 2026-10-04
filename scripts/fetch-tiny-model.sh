#!/bin/bash
# Fetches the tiny Whisper model into BundledModels/ so first launch works offline.
# Runs as a pre-build step. Skips when the model is already complete. Not checked into git.
set -u
DEST="${SRCROOT:-$(cd "$(dirname "$0")/.." && pwd)}/BundledModels/openai_whisper-tiny"
MARK="$DEST/.complete"
[ -f "$MARK" ] && exit 0
echo "Fetching tiny model into $DEST"
mkdir -p "$DEST"
python3 - "$DEST" <<'PY'
import json, os, sys, urllib.request
dest = sys.argv[1]
repo, folder = "argmaxinc/whisperkit-coreml", "openai_whisper-tiny"
tree = json.load(urllib.request.urlopen(f"https://huggingface.co/api/models/{repo}/tree/main/{folder}?recursive=true", timeout=60))
files = [i for i in tree if i["type"] == "file"]
for i in files:
    rel = i["path"].split(folder + "/", 1)[1]
    out = os.path.join(dest, rel)
    if os.path.exists(out) and os.path.getsize(out) == i["size"]: continue
    os.makedirs(os.path.dirname(out), exist_ok=True)
    urllib.request.urlretrieve(f"https://huggingface.co/{repo}/resolve/main/{i['path']}", out)
    if os.path.getsize(out) != i["size"]: raise SystemExit(f"size mismatch: {rel}")
open(os.path.join(dest, ".complete"), "w").write("ok")
print(f"fetched {len(files)} files")
PY
status=$?
if [ $status -ne 0 ]; then
  echo "warning: could not fetch the tiny model"
  # Release builds must carry it. Debug builds can go on without it, the app falls back to a download.
  [ "${CONFIGURATION:-Release}" = "Release" ] && exit 1
fi
exit 0
