#!/usr/bin/env bash
# Decode all WAV files in a folder (recursive) with ffmpeg and report errors.
# Usage: ./wavcheck.sh [folder]     (default: current folder)
set -u
dir="${1:-.}"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found - run ./install_ffmpeg.sh"; exit 1; }

ok=0; bad=0
while IFS= read -r -d '' f; do
  if [[ ! -s "$f" ]]; then
    echo "EMPTY   $f"; ((bad++)); continue
  fi
  err=$(ffmpeg -nostdin -v error -i "$f" -f null - 2>&1)
  if [[ $? -ne 0 || -n "$err" ]]; then
    echo "ERROR   $f"
    echo "$err" | head -n 3 | sed 's/^/        /'
    ((bad++))
  else
    ((ok++))
  fi
done < <(find "$dir" -type f -iname '*.wav' -print0)

echo "OK: $ok   Failed: $bad"
[[ $bad -eq 0 ]]
