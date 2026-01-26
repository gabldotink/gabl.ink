# shellcheck shell=sh
# shellcheck disable=SC2034
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ./build.sh only.
# This is the configuration file for ./build.sh.
# It is ignored by Git, so changes will not be merged to the repository.
# To force add, “git add --force [path]/build_config.sh” will usually work.

# If this is set to true, nonfatal warnings will make the script exit with a nonzero exit code like errors. Default is false.
config_exit_on_warning=false

# If this is set to true, the script will exit with a nonzero exit code if nonfatal warnings were triggered, even if the script was executed fully. If config_exit_on_warning is set to true, nonfatal warnings will always make the script exit with a nonzero exit code. Default is true for testing purposes.
config_exit_nonzero_with_warnings=true

# If this is set to a language ID in the language dictionary, it will be used as the default language if requested values are undefined for the running language and there is no multilingual value. Default is en-US.
config_lang_default=en-US

# If this is set to true, CE (Common Era) and BCE (Before the Common Era) will be used for years instead of AD (anno Domini) and BC (before Christ). Default is false.
config_use_ce=false

# If this is set to any valid ID for a validate link, that link will not be generated. You can specify multiple skipped links by separating the IDs with spaces (e.g. “'w3c vnu'”; remember to use quotation marks around the value). Default is blank.
config_validate_skip=''

# If this is set to any valid ID for a share link, that link will not be generated. You can specify multiple skipped links by separating the IDs with spaces (e.g. “'x bluesky threads'”; remember to use quotation marks around the value). Default is blank.
config_share_skip=''
