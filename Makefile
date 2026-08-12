########################################################################################################################
# Configuration & Variables
########################################################################################################################

#-----------------------------------------------------------
# General Configuration
#-----------------------------------------------------------

SHELL := /bin/bash

DIFF := $(firstword $(shell which colordiff diff))
DIFF_ARGS := -u
MANIFEST_IGNORE := bash_history|bash_secrets
SHELLCHECK := $(shell which shellcheck)
SMOKE_BASH := bash
SHELLCHECK_ARGS := --shell=bash -e SC1090 -e SC1091 -e SC2009 -o require-variable-braces
SHELLCHECK_FILES := $(addprefix ./,$(shell cat MANIFEST)) ./install.sh ./release_check.sh

########################################################################################################################
# Commands
########################################################################################################################

# `make help` needs to be first so it is ran when a bare `make` is called.
.PHONY: help
help: # Show this help screen
	@grep -E '^[a-zA-Z_-]+:.*# .*$$' ${MAKEFILE_LIST} |\
	sort -k1,1 |\
	awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1m%-30s\033[0m %s\n", $$1, $$2}'

########################################################################################################################

.PHONY: copy
copy: # Copy the local bash configs into your home directory (DESTRUCTIVE).
	@while IFS= read -r file; do \
		cp -v "$${file}" "$${HOME}/.$${file}"; \
	done < MANIFEST

.PHONY: diffs
diffs: # Run a diff against your local shell files against this repo's shell files.
	@while IFS= read -r file; do \
		echo "diff ~/.$${file} ./$${file}"; \
		${DIFF} ${DIFF_ARGS} "$${HOME}/.$${file}" "./$${file}" || :; \
	done < MANIFEST

.PHONY: manifest-check
manifest-check: # Validate MANIFEST matches managed bash files.
	@repo_files=$$(ls -1 bash* | grep -Ev '${MANIFEST_IGNORE}' | sort); \
	manifest_files=$$(sort MANIFEST); \
	if [ "$${repo_files}" = "$${manifest_files}" ]; then \
		echo "MANIFEST is up to date"; \
		exit 0; \
	else \
		echo "MANIFEST mismatch:"; \
		${DIFF} ${DIFF_ARGS} --label REPO --label MANIFEST <(echo "$${repo_files}") <(echo "$${manifest_files}"); \
		exit 1; \
	fi

.PHONY: release-check
release-check: # Run release checklist parity checks (docs vs code).
release-check: version-check
release-check: manifest-check
	./release_check.sh

.PHONY: smoke
smoke: # Boot bashrc in a clean interactive shell against a temp HOME.
	@tmp_home=$$(mktemp -d); \
	while IFS= read -r file; do \
		cp "$${file}" "$${tmp_home}/.$${file}"; \
	done < MANIFEST; \
	mkdir -p "$${tmp_home}/.config/urda.bash/extensions.d"; \
	echo 'SMOKE_ORDER="$${SMOKE_ORDER}10-"' > "$${tmp_home}/.config/urda.bash/extensions.d/10-a.sh"; \
	echo 'SMOKE_ORDER="$${SMOKE_ORDER}20"'  > "$${tmp_home}/.config/urda.bash/extensions.d/20-b.sh"; \
	echo 'SMOKE_ORDER="BROKEN"'             > "$${tmp_home}/.config/urda.bash/extensions.d/notes.txt"; \
	env -i HOME="$${tmp_home}" PATH="$${PATH}" TERM=dumb \
		${SMOKE_BASH} -i -c '_urdabash_info && _urdabash_help >/dev/null \
			&& [ "$${URDABASH_LOADED_EXTENSIONS}" = "2" ] \
			&& [ "$${SMOKE_ORDER}" = "10-20" ]' \
		>/dev/null 2>"$${tmp_home}/stderr.log"; \
	status=$$?; \
	grep -vE "job control|ioctl" "$${tmp_home}/stderr.log" >&2 || :; \
	rm -rf "$${tmp_home}"; \
	if [ $${status} -eq 0 ]; then echo "smoke OK"; else echo "smoke FAILED"; fi; \
	exit $${status}

.PHONY: test
test: # Test and check shell scripts for issues.
test: version-check
test: manifest-check
	${SHELLCHECK} ${SHELLCHECK_ARGS} ${SHELLCHECK_FILES}

.PHONY: test-update
test-update: # Test _urdabash_update against localhost:8000 (run 'serve' first).
	@( \
		URDABASH_VERSION="0.0.0" \
		URDABASH_VERSION_URL="http://localhost:8000/VERSION" \
		XDG_CACHE_HOME="$${HOME}/.cache" \
		&& source ./bash_functions \
		&& _urdabash_update \
	)

.PHONY: version-check
version-check: # Check the reported version and code version.
	@file_ver=$$(cat VERSION); \
	var_ver=$$(awk -F\" '/^  readonly URDABASH_VERSION=/{print $$2}' bashrc); \
	if [ "$$file_ver" = "$$var_ver" ]; then \
		echo "VERSION matches '$$var_ver'"; \
		exit 0; \
	else \
		echo "VERSION mismatch: VERSION='$$file_ver', bashrc='$$var_ver'"; \
		exit 1; \
	fi
