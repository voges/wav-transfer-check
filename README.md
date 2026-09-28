# wav-transfer-check

Check WAV files for decoding errors and verify they are unchanged after transfer.

## Requirements

Bash, FFmpeg, and `shasum` or `sha256sum` are required. On macOS, install FFmpeg with Homebrew:

```bash
./install_ffmpeg.sh
```

On Linux, install FFmpeg with your distribution's package manager.

## Transfer

On the sender, run:

```bash
./wavcheck.sh /path/to/folder
./wavhash.sh create /path/to/folder
```

`wavcheck` recursively decodes WAV files. `create` records their SHA-256 checksums in `checksums.sha256` at the folder root.

Transfer the folder, including the manifest. On the receiver, run:

```bash
./wavhash.sh verify /path/to/folder
```

`verify` recursively checks that every WAV file matches its recorded bytes.
