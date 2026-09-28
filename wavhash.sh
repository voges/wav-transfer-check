#!/usr/bin/env bash
# Create or verify SHA-256 checksums for all WAV files in a folder (recursive).
# Usage:
#   ./wavhash.sh create [folder]   -> writes folder/checksums.sha256  (sender)
#   ./wavhash.sh verify [folder]   -> checks against checksums.sha256 (receiver)
set -u
mode="${1:-}"; dir="${2:-.}"
manifest="checksums.sha256"

cd "$dir" || { echo "Folder not found: $dir"; exit 1; }

case "$mode" in
  create)
    find . -type f -iname '*.wav' -print0 | xargs -0 shasum -a 256 > "$manifest"
    echo "$(wc -l < "$manifest" | tr -d ' ') files recorded -> $dir/$manifest"
    ;;
  verify)
    [[ -f "$manifest" ]] || { echo "No $manifest in $dir"; exit 1; }
    # --quiet: print only files that fail or are missing
    if shasum -a 256 -c --quiet "$manifest"; then
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
