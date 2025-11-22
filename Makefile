########################################################################################################################
# Configuration & Variables
########################################################################################################################

#-----------------------------------------------------------
# General Configuration
#-----------------------------------------------------------

DIFF := $(firstword $(shell which colordiff diff))
DIFF_ARGS := -u

SHELLCHECK := $(shell which shellcheck)
SHELLCHECK_ARGS := --shell=bash -e SC1090 -e SC2155
SHELLCHECK_FILES := ./bash*

########################################################################################################################
# Commands
########################################################################################################################

# `make help` needs to be first so it is ran when a bare `make` is called.
.PHONY: help
help: # Show this help screen
	@ack '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) |\
	sort -k1,1 |\
	awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1m%-30s\033[0m %s\n", $$1, $$2}'

########################################################################################################################

.PHONY: copy
copy: # Copy the local bash configs into your home directory (DESTRUCTIVE).
	cp ./bashrc ~/.bashrc
	cp ./bash_aliases ~/.bash_aliases
	cp ./bash_exports ~/.bash_exports
	cp ./bash_profile ~/.bash_profile
	cp ./bash_linux ~/.bash_linux
	cp ./bash_osx ~/.bash_osx

.PHONY: diffs
diffs: # Run a `diff` against your local shell files against this repo's shell files.
	@echo "diff ./bashrc ~/.bashrc"
	@$(DIFF) $(DIFF_ARGS) ./bashrc ~/.bashrc || :
	@echo "diff ./bash_aliases ~/.bash_aliases"
	@$(DIFF) $(DIFF_ARGS) ./bash_aliases ~/.bash_aliases || :
	@echo "diff ./bash_exports ~/.bash_exports"
	@$(DIFF) $(DIFF_ARGS) ./bash_exports ~/.bash_exports || :
	@echo "diff ./bash_profile ~/.bash_profile"
	@$(DIFF) $(DIFF_ARGS) ./bash_profile ~/.bash_profile || :
	@echo "diff ./bash_linux ~/.bash_linux"
	@$(DIFF) $(DIFF_ARGS) ./bash_linux ~/.bash_linux || :
	@echo "diff ./bash_osx ~/.bash_osx"
	@$(DIFF) $(DIFF_ARGS) ./bash_osx ~/.bash_osx || :

.PHONY: test
test: version-check # Test and check shell scripts for issues.
	$(SHELLCHECK) $(SHELLCHECK_ARGS) $(SHELLCHECK_FILES)

.PHONY: version-check
version-check: # Check the reported version and code version.
	@file_ver=$$(cat VERSION); \
	var_ver=$$(awk -F\" '/^readonly URDABASH_VERSION=/{print $$2}' bashrc); \
	if [ "$$file_ver" = "$$var_ver" ]; then \
		echo "VERSION matches '$$var_ver'"; \
		exit 0; \
	else \
		echo "VERSION mismatch: VERSION='$$file_ver', bashrc='$$var_ver'"; \
		exit 1; \
	fi
