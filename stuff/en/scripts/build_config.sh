# ShellCheck warns we don’t have a shebang, but that’s intentional
# shellcheck disable=SC2148
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ./build.sh only.
# This is the configuration file for ./build.sh.
# It is ignored by Git, so changes will not be merged to the repository.
# To force add, “git add --force [path]/build_config.sh” will usually work.

# If this is set to true, non-fatal warnings will make the script exit like an erorr.
# shellcheck disable=SC2034
config_exit_on_warning=false

# If this is set to true, CE (Common Era) and BCE (Before the Common Era) will be used for years instead of AD (anno Domini) and BC (before Christ).
# shellcheck disable=SC2034
config_use_ce=false
