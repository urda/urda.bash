########################################################################################################################
# Variables
########################################################################################################################

SHELLCHECK_ARGS = --shell=bash -e SC1090
SHELLCHECK_FILES = ./bash* ./scripts/*

########################################################################################################################
# `make help` needs to be first so it is ran when a bare `make` is called.
########################################################################################################################

.PHONY: help
help: # Show this help screen
	@ack '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) |\
	sort -k1,1 |\
	awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1m%-30s\033[0m %s\n", $$1, $$2}'

########################################################################################################################
# Commands
########################################################################################################################

.PHONY: diffs
diffs: # Run a `diff` against your local shell files against this repo's shell files.
	./scripts/diffs


.PHONY: test
test: # Test and check shell scripts for issues.
	shellcheck $(SHELLCHECK_ARGS) $(SHELLCHECK_FILES)
