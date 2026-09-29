#!/usr/bin/env bash
# Create or verify SHA-256 checksums for all WAV files in a folder (recursive).
# Usage:
#   ./wavhash.sh create [folder]   -> writes folder/checksums.sha256  (sender)
#   ./wavhash.sh verify [folder]   -> checks against checksums.sha256 (receiver)
set -euo pipefail
mode="${1:-}"; dir="${2:-.}"
manifest="checksums.sha256"

case "$mode" in
  create|verify) ;;
  *) printf 'Usage: %s create|verify [folder]\n' "$0" >&2; exit 1 ;;
esac

if command -v shasum >/dev/null 2>&1; then
  checksum_cmd=(shasum -a 256)
elif command -v sha256sum >/dev/null 2>&1; then
  checksum_cmd=(sha256sum)
else
  printf 'Install shasum or sha256sum to create or verify checksums\n' >&2
  exit 1
fi

cd -- "$dir" || { printf 'Folder not found: %s\n' "$dir" >&2; exit 1; }

tmp_dir=$(mktemp -d ./.wavhash.XXXXXX)
trap 'rm -rf "$tmp_dir"' EXIT

if ! find . -type f -iname '*.wav' -print0 > "$tmp_dir/files"; then
  printf 'Failed to scan folder: %s\n' "$dir" >&2
  exit 1
fi

file_count=0
while IFS= read -r -d '' file_path; do
  file_count=$((file_count + 1))
done < "$tmp_dir/files"

if [[ $file_count -eq 0 ]]; then
  printf 'No WAV files found: %s\n' "$dir" >&2
  exit 1
fi

case "$mode" in
  create)
    xargs -0 "${checksum_cmd[@]}" < "$tmp_dir/files" > "$tmp_dir/$manifest"
    mv "$tmp_dir/$manifest" "$manifest"
    printf '%s files recorded -> %s/%s\n' "$file_count" "$dir" "$manifest"
    ;;
  verify)
    [[ -f "$manifest" ]] || { printf 'No %s in %s\n' "$manifest" "$dir" >&2; exit 1; }
    manifest_count=$(awk 'END { print NR }' "$manifest")
    if [[ $file_count -ne $manifest_count ]]; then
      printf 'WAV count (%s) does not match manifest entry count (%s)\n' \
        "$file_count" "$manifest_count" >&2
      exit 1
    fi
    # --quiet: print only files that fail or are missing
    if "${checksum_cmd[@]}" -c --quiet "$manifest"; then
      printf 'All %s files OK\n' "$manifest_count"
    else
      printf 'Verification failed (see above)\n' >&2
      exit 1
    fi
    ;;
esac
