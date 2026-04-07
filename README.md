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
- Weekly `VERSION` check against GitHub remote (non-blocking).
  - Also supports on-demand version checking with `_urdabash_version_check now`

Should work with `bash 3.2` or higher.

### Aliases

- `clear` - Hard reset the terminal screen.
- `cp` - Copy with overwrite confirmation and verbose output.
- `diff` - Unified diff format, with color via `colordiff` when available.
- `epoch` - Print current unix timestamp (seconds).
- `get_uuid` - Generate a random UUID.
- `headers` - Fetch HTTP response headers only.
- `ll` - Long listing format (`ls -hlF`).
- `moon` - Current moon phase via `wttr.in`.
- `mv` - Move with overwrite confirmation and verbose output.
- `path` - Print `PATH` entries, one per line.
- `publicip` - Print public IP address.
- `serve` - Start a quick HTTP server in the current directory (port 8000).
- `sudo` - Preserves alias expansion when using `sudo`.
- `weather` - Terminal weather forecast via `wttr.in`.

### Functions

- `psg`
  - Search running processes by name. Filters out the `grep` process itself.
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

### Copying files to your `${HOME}`

**WARNING!** This is a **DESTRUCTIVE** operation and copies `bash` files from the project into your `${HOME}`.

```bash
make copy
```

### Project version check

Just run `make version-check`.
