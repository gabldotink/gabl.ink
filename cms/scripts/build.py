#!/usr/bin/env python3
# SPDX-License-Identifier: CC0-1.0

# I’ve been meaning to learn Python anyway

import json
import os
import re
import sys
from datetime import date
from pathlib import Path

# Arch: python-langcodes
from langcodes import Language

def get_var_l10n(dict,key:str|int,format:str,l10n_lang:Language):
    # e.g. get_var_l10n(data["jrco_beta/1"]["location"],"series","text",lang)

    for o in str(l10n_lang),str(l10n_lang.language),"mul","zxx","e":
        if o=="e":
            return None

        if format=="id":
            if "id" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["id"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                return get_var_l10n(dict,key,format,Language.get(dict[key][o]["equal"]))

        if format=="print":
            if "print" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["print"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                return get_var_l10n(dict,key,format,Language.get(dict[key][o]["equal"]))

        if format=="text":
            if "text" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["text"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                return get_var_l10n(dict,key,format,Language.get(dict[key][o]["equal"]))

        if format=="html":
            if "html" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["html"]
            elif "text" in dict.get(key,{}).get(o,{}):
                return dict[key][o]["text"]
            elif "equal" in dict.get(key,{}).get(o,{}):
                return get_var_l10n(dict,key,format,Language.get(dict[key][o]["equal"]))

def get_i_id(i):
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        return obj["id"]

def to_sentence_case(string:str,lang:Language):
    if lang.language=="tok":
        return string
    else:
        return string[:1].upper()+string[1:]

def to_regional_indicators(string:str):
    out_chars=[]
    for ch in string:
        out_chars.append(chr(0x1F1E6 + (ord(ch) - ord("A"))))
    return ''.join(out_chars)

def say_lang(lang:Language,format:str):
    if lang.language in ("en","fr"):
        return f"{to_sentence_case(get_var_l10n(data["dictionaries/language"]["dictionary"][lang.language],"name",format,lang),lang)} ({get_var_l10n(data["dictionaries/region"]["dictionary"][str(lang.region).lower()],"name",format,lang)})"

def msg_l10n(*args,lang:Language,string:str):
    return get_var_l10n(data["dictionaries/string"]["dictionary"],string,"print",lang).format(*args)

def make_nav_button(button:str,lang:Language):
    if button=="f":
        button_arrow="⇦"
        button_id="first"
        button_fl="first"
    elif button=="p":
        button_arrow="←"
        button_id="prev"
        button_fl="first"
    elif button=="n":
        button_arrow="→"
        button_id="next"
        button_fl="last"
    elif button=="l":
        button_arrow="⇨"
        button_id="last"
        button_fl="last"

    r="<div class=nav_button title"

    if data[i_id]["location"]["page"]==data[data[i_id]["location"]["series"]].get(button_fl,{}):
        r+=attribute_string(msg_l10n(msg_l10n(lang=lang,string=f"nav_button_{button_id}_inline"),lang=lang,string="this_is_x_page"))
        r+=">"
    else:
        if button in ("f","l"):
            r+=attribute_string(msg_l10n(get_var_l10n(data[f"{data[i_id]["location"]["series"]}/{data[data[i_id]["location"]["series"]][button_id]}"],"title","text",lang),lang=lang,string="nav_button_page_title"))
        elif button in ("p","n"):
            r+=attribute_string(msg_l10n(get_var_l10n(data[f"{data[i_id]["location"]["series"]}/{data[i_id]["location"][button_id]}"],"title","text",lang),lang=lang,string="nav_button_page_title"))
        r+=">"
        r+="<a href=../../"
        if button in ("f","l"):
            r+=str(data[data[i_id]["location"]["series"]][button_id])
        elif button in ("p","n"):
            r+=str(data[i_id]["location"][button_id])
        r+=f"/{str(lang).lower()}/ hreflang={lang}>"

    r+=f"<span class=nav_button_arrow aria-hidden=true>{button_arrow}</span><br>{msg_l10n(lang=lang,string=f"nav_button_{button_id}")}"

    if data[i_id]["location"]["page"]!=data[data[i_id]["location"]["series"]].get(button_fl,{}):
        r+="</a>"

    r+="</div>"

    return r

# This function assumes the input is plaintext!
def attribute_string(string:str):
    if not string:
        return

    if any(sub in string for sub in ["\t","\n","\v","\f","\r"," ",'"',"'","<","=",">","`"]):
        quoted=True
    else:
        quoted=False

    if quoted:
        if '"' in string and "'" not in string:
            quote_char="'"
        elif "'" in string and '"' not in string:
            quote_char='"'
        elif '"' in string and "'" in string:
            if string.count('"')>string.count("'"):
                quote_char="'"
            else:
                quote_char='"'
        else:
            quote_char='"'

    string=re.sub(r"&(?=[#A-Za-z])","&amp;",string) # &#38;

    if quoted:
        if quote_char=='"':
            string=string.replace('"',"&#34;") # &quot;
        elif quote_char=="'":
            string=string.replace("'","&#39;") # &apos;
        return f"={quote_char}{string}{quote_char}"
    else:
        return f"={string}"

def say_date(d:date,lang:Language):
    r=f"<time datetime={d.year:04}-{d.month:02}-{d.day:02}>"

    if d.year>0 and d.year<1000:
        ad=True
    else:
        ad=False

    if lang.language=="en":
        if lang.region=="US":
            r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",Language.get("en-US"))
            r+=f"\xa0{d.day}, "
            if ad:
                r+='<abbr title="anno Domini">AD</abbr>\xa0'
            r+=str(d.year)
        elif lang.region=="GB":
            r+=f"{d.day}\xa0"
            r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",Language.get("en-GB"))
            r+=" "
            if ad:
                r+='<abbr title="anno Domini">AD</abbr>\xa0'
            r+=d.year
    elif lang.language=="fr":
        if d.day==1:
            r+="1er"
        else:
            r+=d.day
        r+="\xa0"
        r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
        if ad:
            r+=f'{d.year}\xa0<abbr title="après Jésus‐Christ">ap.\xa0J.‐C.</abbr>'
        r+=d.year
    elif lang.language=="es":
        r+=f"{d.day}\xa0de\xa0"
        r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
        r+=" de "
        if ad:
            r+=f'{d.year}\xa0<abbr title="después de Cristo">d.\xa0C.</abbr>'
        r+=d.year
    elif lang.language in ("ja","ko","zh"):
        r+=f"{d.year}{msg_l10n(lang=lang,string="say_date_cjk_year")}"
        r+=f"{d.month}{msg_l10n(lang=lang,string="say_date_cjk_month")}"
        r+=f"{d.day}{msg_l10n(lang=lang,string="say_date_cjk_day")}"

    r+="</time>"

    return r

def id_parent(i_id:str):
    if "/" in i_id:
        return i_id.rpartition("/")[0]
    else:
        return None

def id_base(i_id:str):
    if "/" in i_id:
        return i_id.rpartition("/")[2]
    else:
        return i_id

def expand_parts(parts:list):
    result=set()

    for part in parts:
        if isinstance(part,int):
            result.add(part)
        else:
            start,end=map(int,part.split("-"))
            result.update(range(start,end+1))

    return sorted(result)

if __name__=="__main__":
    script=Path(os.path.abspath(sys.argv[0]))
    scripts=Path(os.path.dirname(script))
    cms=Path(scripts)/".."
    lib=Path(scripts)/"lib"
    dicts=Path(cms)/"dictionaries"
    index=Path(cms)/".."/"i"
    encyclopedia=Path(index)/"encyclopedia"

    data={}

    item_files=[
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

    print("section start: items",file=sys.stderr)

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

            print(f"<title>{msg_l10n(get_var_l10n(data[i_id],"title","text",lang),lang=lang,string="html_title")}</title>",end='')

            print(f"<meta name=description content{attribute_string(get_var_l10n(data[i_id],"description","text",lang))}>",end='')

            print("<meta name=robots content=index,follow>",end='')

            print(f"<link rel=canonical href={canonical} hreflang={lang} type=text/html>",end='')

            # TODO: Only works for one type of depth, but I want to redesign that whole system anyway (sh:349–385)
            styles="../../../../cms/styles"

            # TODO: `if type != comic_page` (sh:349)

            print(f"<link rel=preload href={styles}/{lang.language}.css as=style hreflang=zxx type=text/css>",end='')
            print(f"<link rel=preload href={styles}/comic_page.css as=style hreflang=zxx type=text/css>",end='')
            print(f"<link rel=stylesheet href={styles}/{lang.language}.css hreflang=zxx type=text/css>",end='')
            print(f"<link rel=stylesheet href={styles}/comic_page.css hreflang=zxx type=text/css>",end='')

            print(f'<link rel="external license" href{attribute_string(get_var_l10n(data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]],"url","id",lang))}>',end='')

            # TODO: Prefetches (starting at sh:420)

            print("<meta property=og:type content=article>",end='')
            print(f"<meta property=og:title content{attribute_string(get_var_l10n(data[i_id],"title","text",lang))}>",end='')
            print(f"<meta property=og:description content{attribute_string(get_var_l10n(data[i_id],"description","text",lang))}>",end='')
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

                print(say_lang(l,"html"),end='')

                if l==lang:
                    print("</b>",end='')
                else:
                    print("</a>",end='')
            print("</ul></header>",end='')

            print(f"<h1>{msg_l10n(get_var_l10n(data[i_id],"title","html",lang),lang=lang,string="page_title_html")}</h1>",end='')

            print("<nav class=nav_buttons>",end='')

            print(make_nav_button("f",lang),end='')
            print(make_nav_button("p",lang),end='')
            print(make_nav_button("n",lang),end='')
            print(make_nav_button("l",lang),end='')

            print("</nav>",end='')

            if Path(index/i_id/str(lang).lower()/"video.webm").is_file():
                print("<video controls poster=image.png preload=auto>",end='')
                print("<source src=video.webm type=video/webm>",end='')
                if Path(index/i_id/str(lang).lower()/"subs.vtt").is_file():
                    print(f"<track default src=subs.vtt srclang={lang} kind=subtitles ",end='')
                    print(f"label{attribute_string(say_lang(lang,"text"))}>",end='')
                if Path(index/i_id/str(lang).lower()/"cc.vtt").is_file():
                    print(f"<track src=cc.vtt srclang={lang} kind=captions ",end='')
                    print(f"label{attribute_string(f"{say_lang(lang,"text")}{msg_l10n(lang=lang,string="cc")}")}>",end='')
                print("<p>",end='')
                print(msg_l10n(lang,get_var_l10n(data[data[i_id]["location"]["series"]],"title","text",lang),get_var_l10n(data[i_id],"title","text",lang),get_var_l10n(data[i_id],"title","text",lang),lang=lang,string="video_not_supported"),end='')
                print("</p>",end='')
                print("</video>",end='')
            elif Path(index/i_id/str(lang).lower()/"image.png").is_file():
                print("<picture",end='')
                if get_var_l10n(data[i_id],"tooltip","html",lang) is not None:
                    print(f" title{attribute_string(get_var_l10n(data[i_id],"tooltip","text",lang))}",end='')
                print(">",end='')
                print(f"<img src=image.png fetchpriority=high alt{attribute_string(msg_l10n(lang=lang,string="see_transcript"))}>",end='')
                print("</picture>",end='')

                print("<nav class=nav_buttons>",end='')

            print(make_nav_button("f",lang),end='')
            print(make_nav_button("p",lang),end='')
            print(make_nav_button("n",lang),end='')
            print(make_nav_button("l",lang),end='')

            print("</nav>",end='')

            print("<nav><details><summary>",end='')

            # TODO: Support multiple container depths

            print(msg_l10n(get_var_l10n(data[data[i_id]["location"]["series"]],"title","html",lang),lang=lang,string="series_title_html"),end='')
            print(msg_l10n(data[i_id]["location"]["page"],lang=lang,string="comma_page"),end='')
            print(msg_l10n(get_var_l10n(data[i_id],"title","html",lang),lang=lang,string="page_title_html"),end='')
            print("</summary>",end='')
            print("<ol>",end='')
