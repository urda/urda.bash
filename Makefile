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
SHELLCHECK_ARGS := --shell=bash -e SC1090 -e SC1091 -e SC2009 -e SC2155 -o require-variable-braces
SHELLCHECK_FILES := $(addprefix ./,$(shell cat MANIFEST))

########################################################################################################################
# Commands
########################################################################################################################

# `make help` needs to be first so it is ran when a bare `make` is called.
.PHONY: help
help: # Show this help screen
	@grep -E '^[a-zA-Z_-]+:.*# .*$$' $(MAKEFILE_LIST) |\
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
		$(DIFF) $(DIFF_ARGS) "$${HOME}/.$${file}" "./$${file}" || :; \
	done < MANIFEST

.PHONY: manifest-check
manifest-check: # Validate MANIFEST matches managed bash files.
	@repo_files=$$(ls -1 bash* | grep -Ev '$(MANIFEST_IGNORE)' | sort); \
	manifest_files=$$(sort MANIFEST); \
	if [ "$${repo_files}" = "$${manifest_files}" ]; then \
		echo "MANIFEST is up to date"; \
		exit 0; \
	else \
		echo "MANIFEST mismatch:"; \
		$(DIFF) $(DIFF_ARGS) --label REPO --label MANIFEST <(echo "$${repo_files}") <(echo "$${manifest_files}"); \
		exit 1; \
	fi

.PHONY: test
test: # Test and check shell scripts for issues.
test: version-check
test: manifest-check
	$(SHELLCHECK) $(SHELLCHECK_ARGS) $(SHELLCHECK_FILES)

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
