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

item_files = [
    path
    for path in Path(index).rglob("data.json")
    if path.is_file()
]

for dict in ["copyright_license","disclaimer","language","month","region","script","share_link","string","validate_link"]:
    data[f"dictionaries/{dict}"]={}
    with open(Path(dicts)/f"{dict}.json","r",encoding="utf-8") as f:
        data[f"dictionaries/{dict}"]["dictionary"]=json.load(f)

for i in item_files:
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        i_id=obj.get("id")
        data[i_id]=obj

def get_var_l10n(dict,key,format,l10n_lang):
    # e.g.   get_var_l10n(data["jrco_beta/1"]["location"],"series","text",lang)
    l10n_lang=Language.get(l10n_lang)

    for o in str(l10n_lang),str(l10n_lang.language),"mul","zxx","e":
        if o=="e":
            return False

        if format=="id":
            if "id" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["id"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                get_var_l10n(dict,key,format,data[key][o]["equal"])
            else:
                continue

        # TODO: I might not need printf in Python
        if format=="printf":
            if "printf" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["printf"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                get_var_l10n(dict,key,format,data[key][o]["equal"])
            else:
                continue

        if format=="text":
            if "text" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["text"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                get_var_l10n(dict,key,format,data[key][o]["equal"])
            else:
                continue

        if format=="html":
            if "html" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["html"]
            elif "text" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["text"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                get_var_l10n(dict,key,format,data[key][o]["equal"])
            else:
                continue

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

        canonical=f"https://gabl.ink/i/{data[i_id]["id"]}/{str(lang).lower()}/"

        print("<!DOCTYPE html>")
        print(f"<!-- SPDX-License-Identifier: {data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]]["spdx"]} -->")

        # TODO: Skipping the dir attribute for now, but it should be implemented later
        print(f"<html lang={lang}>",end="")

        print('<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">',end="")

        # TODO: title
        
        print(f'<meta name=description content="{get_var_l10n(data[i_id],"description","text",lang)}">',end="")

        print("<meta name=robots content=index,follow>",end="")

        print(f"<link rel=canonical href={canonical} hreflang={lang} type=text/html>",end="")
