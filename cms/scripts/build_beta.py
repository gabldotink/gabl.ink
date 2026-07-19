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

script = os.path.abspath(sys.argv[0])
scripts = os.path.dirname(script)
lib = Path(scripts) / "lib"
cms = Path(scripts) / ".."
index = Path(cms) / "../i"
encyclopedia = Path(index) / "encyclopedia"

items = subprocess.run(["find", str(index), "-type", "f", "-path", str(index) + "/jrco_beta/*/data.json"], capture_output=True, text=True).stdout.splitlines()

print("section start: items")

for i in items:
    data = json.loads(Path(i).read_text(encoding="utf-8"))
    
    for lang in data["langs"]:
        lang = Language.get(lang)
