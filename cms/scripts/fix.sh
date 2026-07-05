#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

scripts="$(dirname "$0")"

# This fixes problems that my computer introduces for some inexplicable reason
sed -i -- "s/$(printf 'for\240. . . less')/for . . . less/g" "$scripts/../../i/jrco_beta/1/en-us/index.html"
sed -i -- "s/$(printf 'moi \201\220même')/moi‐même/g" "$scripts/../../i/jrco_beta/1/fr-fr/index.html"
