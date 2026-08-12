# Urda's Bash Files

This is a collection of my bash prompt settings, aliases, exports, and other related shell scripts.

## Features

- Exposes the [`XDG Base Directory`](https://specifications.freedesktop.org/basedir/latest/) specification variables.
- Supports loading `bash` shell parts based on host operating system:
  - `bash_linux` - For Linux platforms.
  - `bash_osx` - For macOS platforms (supports `bash-completion` v1 and v2).
- Loads common definitions from:
  - `bash_exports` - Environment variables.
  - `bash_aliases` - Aliases.
  - `bash_functions` - Functions.
- Displays "information lines" in shell:
  - `git` working state information.
  - `screen` session name.
- Understands various tools and tooling in shell:
  - [1Password CLI](https://developer.1password.com/docs/cli/) support.
  - [`direnv`](https://direnv.net/) support.
  - [`fnm`](https://github.com/Schniz/fnm) support.
  - [`pnpm`](https://pnpm.io/) support.
- Weekly `VERSION` check against GitHub remote (non-blocking).
  - Also supports on-demand version checking with `_urdabash_version_check now`
- Extension drop-in directory (`~/.config/urda.bash/extensions.d/`).

Should work with `bash 3.2` or higher.

### Aliases

- `clear` - Hard reset the terminal screen.
- `commitjoke` - Random commit message from `whatthecommit.com`.
- `cp` - Copy with overwrite confirmation and verbose output.
- `dadjoke` - Random dad joke from `icanhazdadjoke.com`.
- `diff` - Unified diff format, with color via `colordiff` when available.
- `epoch` - Print current unix timestamp (seconds).
- `headers` - Fetch HTTP response headers only.
- `ll` - Long listing format (`ls -hlF`).
- `moon` - Current moon phase via `wttr.in`.
- `mv` - Move with overwrite confirmation and verbose output.
- `path` - Print `PATH` entries, one per line.
- `publicip` - Print public IP address.
- `serve` - Start a quick HTTP server in the current directory (port 8000).
- `shrug` - Print the shrug emoticon.
- `sudo` - Preserves alias expansion when using `sudo`.
- `tableflip` - Print the table flip emoticon.
- `tableunflip` - Print the table unflip emoticon.
- `timestamp` - Print current UTC timestamp in ISO 8601 format.
- `weather` - Terminal weather forecast via `wttr.in`.

### Functions

- `bak`
  - Back up a file with a `.bak` extension.
- `coinflip`
  - Flip a coin.
- `get_uuid`
  - Generate a random lowercase UUID (`uuidgen`, Linux kernel, or `python3`, whichever is present).
- `mkcd`
  - Create a directory and `cd` into it in one step.
- `psg`
  - Search running processes by name. Filters out the `grep` process itself.
- `roll`
  - Roll a die (d6 by default, or specify sides).
- `tempdir`
  - Create and `cd` into a disposable temporary directory.
- `unarc`
  - Extract common archive formats by file extension.
- `update_brew` *(macOS only)*
  - Runs `brew update`, `upgrade`, `autoremove`, `cleanup`, and `doctor` in sequence.

#### Internal Functions

These are internal helpers for `urda.bash`. You should not rely on them as a public API.

- `_prepend_path_once`
  - Prepends a value to `${PATH}` once, avoiding duplicates.
- `_source_if_exists`
  - Sources a file if it exists, skips otherwise.
- `_urdabash_help`
  - Prints a quick reference of all aliases and functions.
- `_urdabash_info`
  - Prints information about the current `urda.bash` configuration.
- `_urdabash_update`
  - Self-updates `urda.bash` by fetching the latest files from GitHub. No `git` required.
- `_urdabash_version_check`
  - Checks for a newer `urda.bash` release on GitHub. Pass `now` for an on-demand check.

### Installing

Bootstrap `urda.bash` on a new machine with a single command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/urda/urda.bash/master/install.sh)"
```

### Updating

`urda.bash` checks for new releases weekly in the background. If a newer version is found, a notice is printed on your next shell startup. To update, run:

```bash
_urdabash_update
```

You can also force an on-demand version check:

```bash
_urdabash_version_check now
```

Version check state is stored at `${XDG_STATE_HOME}/urda.bash/` (`~/.local/state/urda.bash/`):

- `last_check` - Timestamp file used to determine when the next fetch is due.
- `remote_version` - Cached remote version string from the last successful fetch.

### Extensions

Drop `*.sh` files into `${XDG_CONFIG_HOME}/urda.bash/extensions.d/`
(`~/.config/urda.bash/extensions.d/`) and they are sourced automatically at
shell startup, in sorted order, after the core urda.bash files and before
`bash_secrets` and `bash_local`. Use `NN-` prefixes to control load order:

```text
10-bw-session.sh
20-work-tools.sh
```

The directory is optional and never touched by the updater. `_urdabash_info`
reports how many extensions loaded via `URDABASH_LOADED_EXTENSIONS`.

#### A Word on Trust

Sourcing an extension is running shell code in every interactive shell, with
everything your user can do. Only place files you trust in this directory,
and inspect anything you did not write yourself before your next shell starts.

### Local Customizations

If `~/.bash_local` exists, it is sourced automatically after all other files. Use this file for machine-specific aliases, functions, or overrides that should survive upgrades.

### Secrets

If `~/.bash_secrets` exists, it is sourced automatically. Use this file for API tokens, credentials, or any other private environment variables.

## Working with `urda.bash` project files

### Get `Makefile` help

You can run a bare `make` or `make help` to display the help screen.

### Comparing to your local bash

After you clone this repo, you can also run a quick `diff` that will compare your local `bash` files against the repo files:

```bash
make diffs
```

### Running tests

This will also run a `make version-check`.

```bash
make test
```

### Smoke test

Boot the managed files in a clean interactive shell against a temporary `HOME`:

```bash
make smoke
```

Set `SMOKE_BASH` to select the shell under test:

```bash
make smoke SMOKE_BASH=/bin/bash
```

### Copying files to your `${HOME}`

**WARNING!** This is a **DESTRUCTIVE** operation and copies `bash` files from the project into your `${HOME}`.

```bash
make copy
```

### Project version check

Just run `make version-check`.

### Release checks

Before cutting a release, run the documentation parity checks:

```bash
make release-check
```

This verifies that every alias and function agrees across the code, the `_urdabash_help` screen, and this README, that each list is alphabetized, and runs the version and MANIFEST checks.
