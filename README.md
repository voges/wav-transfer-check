# wav-transfer-check

Verify WAV files after transfer.

## Setup

Install [Homebrew](https://brew.sh), then run:

```bash
chmod +x *.sh
./install_ffmpeg.sh
```

## Use

On the sender, run these commands:

```bash
./wavcheck.sh /path/to/folder
./wavhash.sh create /path/to/folder
```

`create` stores the SHA-256 sums in `checksums.sha256` inside that folder.

Send the folder to the receiver (e.g., via iCloud Drive).
Then run this command.

```bash
./wavhash.sh verify /path/to/folder
```

All scripts recurse into subfolders.
