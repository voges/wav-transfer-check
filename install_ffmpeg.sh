#!/usr/bin/env bash
# Install ffmpeg via Homebrew.
# Usage: ./install_ffmpeg.sh
set -euo pipefail

# Homebrew location on Apple Silicon
BREW=/opt/homebrew/bin/brew

# Homebrew must be installed separately; see https://brew.sh
if [[ -x "$BREW" ]]; then
  eval "$($BREW shellenv)"
elif ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh and run this script again."
  exit 1
fi

# Install or upgrade ffmpeg
if brew list ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg already installed - checking for updates..."
  brew upgrade ffmpeg
else
  echo "Installing ffmpeg..."
  brew install ffmpeg
fi

# Check
echo
ffmpeg -version | head -n 1
echo "Done. Ensure Homebrew is initialized in new terminals so ffmpeg is on PATH."
