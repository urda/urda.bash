# CHANGELOG

## 1.0.0

- In late 2025, `urda.bash` got a fresh coat of paint.
- `bashrc`
  - Introduced `URDABASH_*` variables as `readonly`.
  - Setup `XDG` environment variables.
  - Cleaned up sourcing with `_source_if_exists`.
  - Setup `case` against `uname` result for OS imports.
  - Cleaned up `pyenv` import, removed `workon` and `deactivate`. Use `.python-version` to "switch `venvs`.
  - `_set_ps1` got a full overhaul. Different "lines" are now functions, and are built in a single `prompt` result.
  - `PROMPT_COMMAND` is no longer just replaced with our `ps1` command.
  - `urda.bash` can now check GitHub for new versions (requires `curl` or `wget`).
- `bash_aliases`
  - Moved `colordiff` up to just `alias diff` setup area.
  - Removed `/usr/bin/dircolors` section (for now).
- `bash_exports`
  - Moved `CLICOLOR` to `bash_osx`.
  - Added `GPG` values.
- `bash_linux`
  - Joins the `urda.bash` family for any `Linux` needs.
- `bash_osx`
  - Added simple "guard" to top of file.
  - Updated `env` variables.
  - Cleaned up `brew` and related tooling imports.
  - Cleaned up `update_brew` function.
- `Makefile`
  - Now supports `make version-check` and will be invoked with `make test` as well.
- `VERSION`
  - Version file created for remote version checking.
- GitHub
  - Added a `pull_request_template` mostly for tracking releases.
  - Updated `testing.yaml` to latest `runs-on` and `actions/checkout
- General, Other
  - Added a `LICENSE` file to repo, just set to `MIT`.
