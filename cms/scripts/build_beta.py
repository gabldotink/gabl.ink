#!/usr/bin/env python3
# SPDX-License-Identifier: CC0-1.0

# I’ve been meaning to learn Python anyway

import json
import os
import sys
from pathlib import Path

# Arch: python-langcodes
from langcodes import Language

# Use LF on all platforms (Windows)
sys.stdout.reconfigure(newline="\n")

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
    data[f"dictionaries/{dict}"]["id"]=f"dictionaries/{dict}"
    data[f"dictionaries/{dict}"]["type"]="dictionary"
    data[f"dictionaries/{dict}"]["dictionary_name"]=dict
    with open(Path(dicts)/f"{dict}.json","r",encoding="utf-8") as f:
        data[f"dictionaries/{dict}"]["dictionary"]=json.load(f)

for i in item_files:
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        i_id=obj.get("id")
        data[i_id]=obj

def get_var_l10n(dict,key,format,l10n_lang):
    # e.g.   get_var_l10n(data["jrco_beta/1"]["location"],"series","text",lang)

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

        if format=="print":
            if "print" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["print"]
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

def to_sentence_case(string):
    if lang.language=="tok":
        return string
    else:
        return string[:1].upper()+string[1:]

def to_regional_indicators(string):
    out_chars=[]
    for ch in string:
        out_chars.append(chr(0x1F1E6 + (ord(ch) - ord("A"))))
    return ''.join(out_chars)

def say_lang(lang,format):
    if lang.language in ("en","fr"):
        return print(f"{to_sentence_case(get_var_l10n(data["dictionaries/language"]["dictionary"][lang.language],"name",format,lang))} ({get_var_l10n(data["dictionaries/region"]["dictionary"][str(lang.region).lower()],"name",format,lang)})",end='')

def print_l10n(*args,lang,string):
    return get_var_l10n(data["dictionaries/string"]["dictionary"],string,"print",lang).format(*args)

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

        # TODO: Skipping the dir attribute for now, but it should be implemented later (sh:338)
        print(f"<html lang={lang}>",end='')

        print('<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">',end='')

        print(f"<title>{print_l10n(get_var_l10n(data[i_id],"title","text",lang),lang=lang,string="html_title")}</title>")

        print(f'<meta name=description content="{get_var_l10n(data[i_id],"description","text",lang)}">',end='')

        print("<meta name=robots content=index,follow>",end='')

        print(f"<link rel=canonical href={canonical} hreflang={lang} type=text/html>",end='')

        # TODO: Only works for one type of depth, but I want to redesign that whole system anyway (sh:349–385)
        styles="../../../../cms/styles"

        # TODO: `if type != comic_page` (sh:349)

        print(f"<link rel=preload href={styles}/{lang.language}.css as=style hreflang=zxx type=text/css>",end='')
        print(f"<link rel=preload href={styles}/comic_page.css as=style hreflang=zxx type=text/css>",end='')
        print(f"<link rel=stylesheet href={styles}/{lang.language}.css hreflang=zxx type=text/css>",end='')
        print(f"<link rel=stylesheet href={styles}/comic_page.css hreflang=zxx type=text/css>",end='')

        print(f'<link rel="external license" href="{get_var_l10n(data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]],"url","id",lang)}">',end='')

        # TODO: Prefetches (starting at sh:420)

        print("<meta property=og:type content=article>",end='')
        print(f'<meta property=og:title content="{get_var_l10n(data[i_id],"title","text",lang)}">',end='')
        print(f'<meta property=og:description content="{get_var_l10n(data[i_id],"description","text",lang)}">',end='')
        print("<meta property=og:site_name content=gabl.ink>",end='')
        print(f"<meta property=og:url content={canonical}>",end='')
        print(f"<meta property=og:image content={canonical}image.png>",end='')
        # TODO: video_exists (sh:322–332, sh:454)
        # TODO: Should this use babel or something instead? There’s probably not really much point
        print(f"<meta property=og:locale content={lang.language}_{lang.territory}>",end='')

        print("<header>",end='')
        print("<a href=https://gabl.ink/ id=gabldotink_logo>gabl.ink</a>",end='')

        print("<ul id=lang_select>",end='')
        for l in sorted(data[i_id]["langs"]):
            l=Language.get(l)

            print(f"<li data-lang_select_flag={to_regional_indicators(l.region)}>",end='')

            if l==lang:
                print("<b>",end='')
            else:
                print(f"<a lang={l} href=../{str(l).lower()}/ hreflang={l}>",end='')

            say_lang(l,"html")

            if l==lang:
                print("</b>",end='')
            else:
                print("</a>",end='')
        print("</ul></header>",end='')
