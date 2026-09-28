#!/usr/bin/env bash
# Create or verify SHA-256 checksums for all WAV files in a folder (recursive).
# Usage:
#   ./wavhash.sh create [folder]   -> writes folder/checksums.sha256  (sender)
#   ./wavhash.sh verify [folder]   -> checks against checksums.sha256 (receiver)
set -u
mode="${1:-}"; dir="${2:-.}"
manifest="checksums.sha256"

if command -v shasum >/dev/null 2>&1; then
  checksum_cmd=(shasum -a 256)
elif command -v sha256sum >/dev/null 2>&1; then
  checksum_cmd=(sha256sum)
else
  echo "Install shasum or sha256sum to create or verify checksums" >&2
  exit 1
fi

cd "$dir" || { echo "Folder not found: $dir"; exit 1; }

case "$mode" in
  create)
    if ! IFS= read -r -d '' first_wav < <(find . -type f -iname '*.wav' -print0); then
      echo "No WAV files found: $dir" >&2
      exit 1
    fi
    find . -type f -iname '*.wav' -print0 | xargs -0 "${checksum_cmd[@]}" > "$manifest"
    echo "$(wc -l < "$manifest" | tr -d ' ') files recorded -> $dir/$manifest"
    ;;
  verify)
    [[ -f "$manifest" ]] || { echo "No $manifest in $dir"; exit 1; }
    # --quiet: print only files that fail or are missing
    if "${checksum_cmd[@]}" -c --quiet "$manifest"; then
      echo "All $(wc -l < "$manifest" | tr -d ' ') files OK"
    else
      echo "Verification failed (see above)"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 create|verify [folder]"; exit 1
    ;;
esac
