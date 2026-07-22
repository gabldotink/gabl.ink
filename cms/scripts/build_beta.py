#!/usr/bin/env python3
# SPDX-License-Identifier: CC0-1.0

# I’ve been meaning to learn Python anyway

import sys
import os
from pathlib import Path
import subprocess
import json
# Arch: python-langcodes
from langcodes import Language

script=Path(os.path.abspath(sys.argv[0]))
scripts=Path(os.path.dirname(script))
cms=Path(scripts)/".."
lib=Path(scripts)/"lib"
dicts=Path(cms)/"dictionaries"
index=Path(cms)/".."/"i"
encyclopedia=Path(index)/"encyclopedia"

data={}

item_files=subprocess.run(["find",Path(index),"-type","f","-name","data.json"],capture_output=True,text=True).stdout.splitlines()

for dict in ["copyright_license","disclaimer","language","month","region","script","share_link","string","validate_link"]:
    data[f"dictionaries/{dict}"]={}
    with open(Path(dicts)/f"{dict}.json","r",encoding="utf-8") as f:
        data[f"dictionaries/{dict}"]["dictionary"]=json.load(f)

for i in item_files:
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        i_id=obj.get("id")
        data[i_id]=obj

print(data["dictionaries/copyright_license"])

#def get_var_l10n(key,format,dict):
#    try:
#        dict
#    except NameError:
#        dict=data
#    else:
#        dict=f"dict_{dict}"
#
#    for o in lang,lang.language,"mul","zxx","e":
#        if format=="e":
#            return False
#
#        if format=="id":
#            try:
#                dict[key][o]["id"]
#            except KeyError:
#                try:
#                    dict[key][o]["equal"]
#                except KeyError:
#                    continue
#                else:
#
#            else:
#                return dict[key][o]["id"]

def get_i_id(i):
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        return obj["id"]

print("section start: items")

for i in item_files:
    i_id=get_i_id(i)
    
    if data[i_id]["type"] != "comic_page":
        continue

    for lang in data[i_id]["langs"]:
        lang=Language.get(lang)

        canonical=f"https://gabl.ink/i/{str(data[i_id]["id"])}/{str(lang).lower()}/"

        print("<!DOCTYPE html>")
        print(f"<!-- SPDX-License-Identifier: {data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]]["spdx"]} -->")

        # TODO: Skipping the dir attribute for now, but it should be implemented later
        print(f"<html lang={lang}>",end="")

        print('<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">',end="")

        # This is when it starts getting hard
