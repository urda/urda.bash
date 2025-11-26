# Urda's Bash Files

This is a collection of my bash prompt settings, aliases, exports, and other related shell scripts.

# `urda.bash` Features

- Exposes the [`XDG Base Directory`](https://specifications.freedesktop.org/basedir/latest/) specification variables.
- Supports loading `bash` shell parts based on host operating system:
  - `bash_linux` - For Linux platforms.
  - `bash_osx` - For macOS platforms.
- Displays "information lines" in shell:
  - `git` working state information.
  - `screen` session name.
  - `virtualenv` / `pyenv` environment names.
- Understands various tools and tooling in shell:
  - [`direnv`](https://direnv.net/) support.
  - [`nvm`](https://github.com/nvm-sh/nvm) support.
  - [`pyenv`](https://github.com/pyenv/pyenv) support.
- Weekly `VERSION` check against GitHub remote.
  - Also supports on-demand version checking with `_urdabash_version_check now`

Should work with `bash 3.2` or higher.

# Working with `urda.bash` project files

## Get `Makefile` help

You can run a bare `make` or `make help` to display the help screen.

## Comparing to your local bash

After you clone this repo, you can also run a quick `diff` that will compare your local `bash` files against the repo files:

```bash
make diffs
```

## Running tests

This will also run a `make version-check`.

```bash
make test
```

## Copying files to your `${HOME}`

**WARNING!** This is a **DESTRUCTIVE** operation and copies `bash` files from the project into your `${HOME}`.

```bash
make copy
```

## Project version check

Just run `make version-check`.
