# WAV Transfer Check

Check WAV files before sending them and confirm they are unchanged after transfer.

## Setup

On macOS, run this to install or update FFmpeg:

```bash
./install_ffmpeg.sh
```

Homebrew must be installed first. If needed, get it from [brew.sh](https://brew.sh).

On Linux, install FFmpeg using your usual software installer. Run the commands below from the folder containing these scripts, replacing the example path with your WAV folder.

## Before Sending

Run these commands on the computer that has the original WAV files:

```bash
./wavcheck.sh "/path/to/your/folder"
./wavhash.sh create "/path/to/your/folder"
```

Continue only if the first command reports `Failed: 0`. The second command creates `checksums.sha256` inside your WAV folder.

Copy the WAV folder, including `checksums.sha256`, to the receiving computer. Then run:

```bash
./wavhash.sh verify "/path/to/your/folder"
```

`All N files OK` means the WAV files match the originals. A verification failure means files are missing or have changed.
