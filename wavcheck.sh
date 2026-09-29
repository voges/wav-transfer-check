#!/usr/bin/env bash
# Decode all WAV files in a folder (recursive) with ffmpeg and report errors.
# Usage: ./wavcheck.sh [folder]     (default: current folder)
set -euo pipefail
dir="${1:-.}"

[[ -d "$dir" ]] || { echo "Folder not found: $dir" >&2; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg not found - run ./install_ffmpeg.sh"; exit 1; }

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/wavcheck.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT

if ! find "$dir" -type f -iname '*.wav' -print0 > "$tmp_dir/files"; then
  printf 'Failed to scan folder: %s\n' "$dir" >&2
  exit 1
fi

ok=0; bad=0; files=0
while IFS= read -r -d '' f; do
  files=$((files + 1))
  if [[ ! -s "$f" ]]; then
    printf 'EMPTY   %s\n' "$f"
    bad=$((bad + 1))
    continue
  fi
  if ffmpeg -nostdin -v error -i "$f" -f null - > /dev/null 2> "$tmp_dir/ffmpeg.log"; then
    ffmpeg_status=0
  else
    ffmpeg_status=$?
  fi
  if [[ $ffmpeg_status -ne 0 || -s "$tmp_dir/ffmpeg.log" ]]; then
    printf 'ERROR   %s\n' "$f"
    sed -n '1,3{s/^/        /;p;}' "$tmp_dir/ffmpeg.log"
    bad=$((bad + 1))
  else
    ok=$((ok + 1))
  fi
done < "$tmp_dir/files"

if [[ $files -eq 0 ]]; then
  printf 'No WAV files found: %s\n' "$dir" >&2
  exit 1
fi

printf 'OK: %s   Failed: %s\n' "$ok" "$bad"
[[ $bad -eq 0 ]]
