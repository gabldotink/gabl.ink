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
# Arch: python-jq
import jq

script=os.path.abspath(sys.argv[0])
scripts=os.path.dirname(script)
cms=Path(scripts)/".."
lib=Path(scripts)/"lib"
dicts=Path(cms)/"dictionaries"
index=Path(cms)/"../i"
encyclopedia=Path(index)/"encyclopedia"

data={}

items=subprocess.run(["find",Path(index),"-type","f","-name","data.json"],capture_output=True,text=True).stdout.splitlines()

for i in items:
    i_id=jq.compile(".id").input(Path(i).read_text(encoding="utf-8")).first()
    data[i_id]=json.loads(Path(i).read_text(encoding="utf-8"))

for dict in ["copyright_license","disclaimer","language","month","region","script","share_link","string","validate_link"]:
    globals()[f"dict_{dict}"]=json.loads((Path(dicts)/f"{dict}.json").read_text(encoding="utf-8"))

def get_var_l10n(key,format,dict):
    try:
        dict
    except NameError:
        dict=data
    else:
        dict=f"dict_{dict}"

    for o in lang,lang.language,"mul","zxx","e":
        if format=="e":
            return False

        if format=="id":
            try:
                dict[key][o]["id"]
            except KeyError:
                try:
                    dict[key][o]["equal"]
                except KeyError:
                    continue
                else:

            else:
                return dict[key][o]["id"]
                

print("section start: items")

for i in items:
    data=json.loads(Path(i).read_text(encoding="utf-8"))

    for lang in data["langs"]:
        lang=Language.get(lang)

        canonical="https://gabl.ink/i/"+str(data["id"])+"/"+str(lang).lower()+"/"

        print("<!DOCTYPE html>")
        print("<!-- SPDX-License-Identifier: "+dict_copyright_license[data["copyright"]["license"][0]]["spdx"]+" -->")

        # TODO: Skipping the dir attribute for now, but it should be implemented later
        print("<html lang="+str(lang)+">",end="")

        print('<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">',end="")

        # This is when it starts getting hard
