# mig8447's Bash Scripts
A repository for Bash scripts I've written over time.

## Functions

### `record_terminal` (alias `recterm`)
![Date Added: 04-MAR-19](https://img.shields.io/badge/date%20added-04--MAR--19-lightgrey.svg)

This function is a wrapper of the `script` program included in several *UNIX-like* operating systems/distributions. It records the terminal session capturing timing information to be played later via [`play_terminal_recording`](#play_terminal_recording-alias-playterm).

**NOTE**: Once the recording is started, you can exit by typing the `exit` command

#### Prerequisites

You need to have the `script` program installed in your environment and accessible in the `$PATH`. In Linux, this program normally comes in a package called `util-linux` or the newer `util-linux-ng`

#### Example

```
$ record_terminal
INFO: record_terminal: Now Recording "recording_20190304_184317"...
Script started, file is /.../recording_20190304_184317.ts
$ whoami
mig8447
$ exit
exit
Script done, file is /.../recording_20190304_184317.ts
INFO: record_terminal: "recording_20190304_184317" recording has finished
```

#### Output

This function produces two files:

- `<RECORDING_NAME>.timing.ts`: A file containing the timing information for playback purposes
- `<RECORDING_NAME>.ts`: The actual typescript which will contain the text of the recorded terminal session including all escaping sequences for commands and special keys, which in turn makes this not *human-friendly*

Such files are written to a directory designated by the `$TERMINAL_TYPESCRIPTS_DIR` which by default gets created under `"$HOME"'/terminal_typescripts'` by the `install.sh` script

#### Parameters

Parameters for this function are positional:

1. **The recording name**: If provided this will be the prefix for the file names to which the recording will be saved to. If this parameter is omitted or a zero-length string, then the recording name gets populated with the `recording_` prefix and the current date in `%Y%m%d_%H%M%S` format.

#### Exit Codes

This wrapper, for most cases, will return the exit codes provided by the `script` tool. The only case on which it will return the custom exit code 1 is whenever the file pair that the user is trying to write to already exists, this preventing the user from overwriting or appending output to a file when using this wrapper because that's usually not the desired behavior.

### `play_terminal_recording` (alias `playterm`)
![Date Added: 04-MAR-19](https://img.shields.io/badge/date%20added-04--MAR--19-lightgrey.svg)

This function is a wrapper of the `scriptreplay` program included in several *UNIX-like* operating systems/distributions. It plays-back a terminal session recorded using [`record_terminal`](#record_terminal-alias-recterm) function.

**NOTE:** Once started, you can stop the terminal recording playback hitting `Ctrl + C`

#### Prerequisites

You need to have the `scriptreplay` program installed in your environment and accessible in the `$PATH`. In Linux, this program normally comes in a package called `util-linux` or the newer `util-linux-ng`

#### Example

```
$ play_terminal_recording recording_20190304_184317
INFO: play_terminal_recording: Now Playing "recording_20190304_184317"...
$ whoami
mig8447
$ exit

INFO: play_terminal_recording: "recording_20190304_184317" ended
```

#### Input

This function requires two input files:

- `<RECORDING_NAME>.timing.ts`: A file containing the timing information for playback purposes
- `<RECORDING_NAME>.ts`: The actual typescript which contains the text of the recorded terminal session

Such files must be located within a directory designated by the `$TERMINAL_TYPESCRIPTS_DIR` which by default gets created under `"$HOME"'/terminal_typescripts'` by the `install.sh` script

#### Parameters

Parameters for this function are positional:

1. **The recording name**: The name passed in the first parameter of the `record_terminal` function.
2. **The playback speed**: The speed at which the recording will be played (e.g. 1 for 1x playback, 0.5 for 0.5x playback, 20 for 20x playback, etc.)

#### Exit Codes

This wrapper, for most cases, will return the exit codes provided by the `scriptreplay` tool. The only cases on which it will return the custom exit code 1 is whenever the file pair that the user is trying to play doesn't exist, is not a file or is not readable by the current user, or whenever the user doesn't pass any recording name as the first parameter.
