# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ./build.sh only.
# This is the configuration file for ./build.sh.
# It is ignored by Git, so changes will not be merged to the repository.
# To force add, “git add --force [path]/build_config.sh” will usually work.

# If this is set to true, non-fatal warnings will make the script exit with a non-zero exit code like errors. Default is false.
# shellcheck disable=SC2034
config_exit_on_warning=false

# If this is set to true, the script will exit with a non-zero exit code if non-fatal warnings were triggered, even if the script was executed fully. If config_exit_on_warning is set to true, non-fatal warnings will always make the script exit with a non-zero exit code. Default is true for testing purposes.
# shellcheck disable=SC2034
config_exit_nonzero_with_warnings=true

# If this is set to true, CE (Common Era) and BCE (Before the Common Era) will be used for years instead of AD (anno Domini) and BC (before Christ). Default is false.
# shellcheck disable=SC2034
config_use_ce=false

# If this is set to true, mentions of the social media platform X will instead refer to Twitter. The HTML ID will still be “x”, and URLs will still point to x.com. Default is false.
config_use_twitter=false
