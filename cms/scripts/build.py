#!/usr/bin/env python3
# SPDX-License-Identifier: CC0-1.0

# I’ve been meaning to learn Python anyway

import json
import os
import re
import shutil
import sys
import tempfile
from datetime import date
from pathlib import Path

# Arch: python-langcodes
from langcodes import Language

def get_var_l10n(index,key:str|int,format:str,l10n_lang:Language)->str:
    # e.g. get_var_l10n(data["jrco_beta/1"]["location"],"series","text",lang)

    for o in str(l10n_lang),str(l10n_lang.language),"mul","zxx","e":
        if o=="e":
            return None

        if format=="id":
            if "id" in index.get(key,{}).get(o,{}):
                return index[key][o]["id"]
            elif "equal" in index.get(key,{}).get(o,{}):
                return get_var_l10n(index,key,format,Language.get(index[key][o]["equal"]))

        if format=="print":
            if "print" in index.get(key,{}).get(o,{}):
                return index[key][o]["print"]
            elif "equal" in index.get(key,{}).get(o,{}):
                return get_var_l10n(index,key,format,Language.get(index[key][o]["equal"]))

        if format=="text":
            if "text" in index.get(key,{}).get(o,{}):
                return index[key][o]["text"]
            elif "equal" in index.get(key,{}).get(o,{}):
                return get_var_l10n(index,key,format,Language.get(index[key][o]["equal"]))

        if format=="html":
            if "html" in index.get(key,{}).get(o,{}):
                return index[key][o]["html"]
            elif "text" in index.get(key,{}).get(o,{}):
                return index[key][o]["text"]
            elif "equal" in index.get(key,{}).get(o,{}):
                return get_var_l10n(index,key,format,Language.get(index[key][o]["equal"]))

def get_i_id(i:Path)->str:
    with open(i,"r",encoding="utf-8") as f:
        obj=json.load(f)
        return obj["id"]

def to_sentence_case(string:str,lang:Language)->str:
    if lang.language=="tok":
        return string
    else:
        return f"{string[:1].upper()}{string[1:]}"

def to_regional_indicators(string:str)->str:
    out_chars=[]
    for ch in string:
        out_chars.append(chr(0x1F1E6+(ord(ch)-ord("A"))))
    return ''.join(out_chars)

def say_lang(lang:Language,format:str)->str:
    if lang.language in ("en","fr"):
        return f'{to_sentence_case(get_var_l10n(data["dictionaries/language"]["dictionary"][lang.language],"name",format,lang),lang)} ({get_var_l10n(data["dictionaries/region"]["dictionary"][str(lang.region).lower()],"name",format,lang)})'

def msg_l10n(*args,lang:Language,string:str):
    return get_var_l10n(data["dictionaries/string"]["dictionary"],string,"print",lang).format(*args)

def make_nav_button(button:str,lang:Language)->str:
    button_arrow,button_id,button_fl={
        "f":("⇦","first","first"),
        "p":("←","prev","first"),
        "n":("→","next","last"),
        "l":("⇨","last","last"),
    }[button]

    r:str="<div class=nav_button title"

    if data[i_id]["location"]["page"]==data[data[i_id]["location"]["series"]].get(button_fl,{}):
        r+=attribute_string(msg_l10n(msg_l10n(lang=lang,string=f"nav_button_{button_id}_inline"),lang=lang,string="this_is_x_page"))
        r+=">"
    else:
        if button in ("f","l"):
            r+=attribute_string(msg_l10n(get_var_l10n(data[f'{data[i_id]["location"]["series"]}/{data[data[i_id]["location"]["series"]][button_id]}'],"title","text",lang),lang=lang,string="nav_button_page_title"))
        elif button in ("p","n"):
            r+=attribute_string(msg_l10n(get_var_l10n(data[f'{data[i_id]["location"]["series"]}/{data[i_id]["location"][button_id]}'],"title","text",lang),lang=lang,string="nav_button_page_title"))
        r+=">"
        r+="<a href=../../"
        if button in ("f","l"):
            r+=str(data[data[i_id]["location"]["series"]][button_id])
        elif button in ("p","n"):
            r+=str(data[i_id]["location"][button_id])
        r+=f"/{str(lang).lower()}/ hreflang={lang}>"

    r+=f'<span class=nav_button_arrow aria-hidden=true>{button_arrow}</span><br>{msg_l10n(lang=lang,string=f"nav_button_{button_id}")}'

    if data[i_id]["location"]["page"]!=data[data[i_id]["location"]["series"]].get(button_fl,{}):
        r+="</a>"

    r+="</div>"

    return r

# This function assumes the input is plaintext!
def attribute_string(string:str)->str:
    if not string:
        return

    quoted:bool

    if any(sub in string for sub in ["\t","\n","\v","\f","\r"," ",'"',"'","<","=",">","`"]):
        quoted=True
    else:
        quoted=False

    quote_char:str

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

    string:str=re.sub(r"&(?=[#A-Za-z])","&amp;",string) # &#38;

    if quoted:
        if quote_char=='"':
            string:str=string.replace('"',"&#34;") # &quot;
        elif quote_char=="'":
            string:str=string.replace("'","&#39;") # &apos;
        return f"={quote_char}{string}{quote_char}"
    else:
        return f"={string}"

def say_date(d:date,lang:Language)->str:
    r:str=f"<time datetime={d.year:04}-{d.month:02}-{d.day:02}>"

    ad:bool

    if d.year>0 and d.year<1000:
        ad=True
    else:
        ad=False

    if lang.language=="en":
        if lang.region=="US":
            r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
            r+=f"\xa0{d.day}, "
        elif lang.region=="GB":
            r+=f"{d.day}\xa0"
            r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
            r+=" "
        if ad:
            r+='<abbr title="anno Domini">AD</abbr>\xa0'
            r+=str(d.year)
    elif lang.language=="fr":
        if d.day==1:
            r+="1er"
        else:
            r+=str(d.day)
        r+="\xa0"
        r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
        if ad:
            r+=f'{d.year}\xa0<abbr title="après Jésus‐Christ">ap.\xa0J.‐C.</abbr>'
        r+=str(d.year)
    elif lang.language=="es":
        r+=f"{d.day}\xa0de\xa0"
        r+=get_var_l10n(data["dictionaries/month"]["dictionary"]["months"][d.month-1],"name","html",lang)
        r+=" de "
        if ad:
            r+=f'{d.year}\xa0<abbr title="después de Cristo">d.\xa0C.</abbr>'
        r+=str(d.year)
    elif lang.language in ("ja","ko","zh"):
        r+=f'{d.year}{msg_l10n(lang=lang,string="say_date_cjk_year")}'
        r+=f'{d.month}{msg_l10n(lang=lang,string="say_date_cjk_month")}'
        r+=f'{d.day}{msg_l10n(lang=lang,string="say_date_cjk_day")}'

    r+="</time>"

    return r

def id_parent(i_id:str)->str:
    if "/" in i_id:
        return i_id.rpartition("/")[0]
    else:
        return None

def id_base(i_id:str)->str:
    if "/" in i_id:
        return i_id.rpartition("/")[2]
    else:
        return i_id

def expand_parts(parts:list)->list:
    result=set()

    for part in parts:
        if isinstance(part,int):
            result.add(part)
        else:
            start,end=map(int,part.split("-"))
            result.update(range(start,end+1))

    return sorted(result)

if __name__=="__main__":
    script:Path=Path(os.path.abspath(sys.argv[0]))
    scripts:Path=Path(os.path.dirname(script))
    cms:Path=Path(scripts)/".."
    lib:Path=Path(scripts)/"lib"
    dicts:Path=Path(cms)/"dictionaries"
    index:Path=Path(cms)/".."/"i"
    encyclopedia:Path=Path(index)/"encyclopedia"

    data:dict={}

    item_files:list=[
        path
        for path in Path(index).rglob("data.json")
        if path.is_file()
    ]

    for dictionary in ["copyright_license","disclaimer","language","month","region","script","share_link","string","validate_link"]:
        data[f"dictionaries/{dictionary}"]={}
        data[f"dictionaries/{dictionary}"]["id"]=f"dictionaries/{dictionary}"
        data[f"dictionaries/{dictionary}"]["type"]="dictionary"
        data[f"dictionaries/{dictionary}"]["dictionary_name"]=dictionary
        with open(Path(dicts)/f"{dictionary}.json","r",encoding="utf-8") as f:
            data[f"dictionaries/{dictionary}"]["dictionary"]=json.load(f)

    for i in item_files:
        with open(i,"r",encoding="utf-8") as f:
            obj=json.load(f)
            obj_id=obj.get("id")
            data[obj_id]=obj

    sys.stderr.write("section start: items\n")

    for i in item_files:
        i_id:str=get_i_id(i)

        if data[i_id]["type"]!="comic_page":
            continue

        for lang in data[i_id]["langs"]:
            lang:Language=Language.get(lang)

            canonical:str=f'https://gabl.ink/i/{data[i_id]["id"]}/{str(lang).lower()}/'

            F:list=["<!DOCTYPE html>\n"]

            F.append(f'<!-- SPDX-License-Identifier: {data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]]["spdx"]} -->\n')

            # TODO: Skipping the dir attribute for now, but it should be implemented later (sh:338)
            F.append(f"<html lang={lang}>")

            F.append('<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">')

            F.append(f'<title>{msg_l10n(get_var_l10n(data[i_id],"title","text",lang),lang=lang,string="html_title")}</title>')

            F.append(f'<meta name=description content{attribute_string(get_var_l10n(data[i_id],"description","text",lang))}>')

            F.append("<meta name=robots content=index,follow>")

            F.append(f"<link rel=canonical href={canonical} hreflang={lang} type=text/html>")

            # TODO: Only works for one type of depth, but I want to redesign that whole system anyway (sh:349–385)
            styles:str="../../../../cms/styles"

            # TODO: `if type != comic_page` (sh:349)

            F.append(f"<link rel=preload href={styles}/{lang.language}.css as=style hreflang=zxx type=text/css>")
            F.append(f"<link rel=preload href={styles}/comic_page.css as=style hreflang=zxx type=text/css>")
            F.append(f"<link rel=stylesheet href={styles}/{lang.language}.css hreflang=zxx type=text/css>")
            F.append(f"<link rel=stylesheet href={styles}/comic_page.css hreflang=zxx type=text/css>")

            F.append(f'<link rel="external license" href{attribute_string(get_var_l10n(data["dictionaries/copyright_license"]["dictionary"][data[i_id]["copyright"]["license"][0]],"url","id",lang))}>')

            # TODO: Prefetches (starting at sh:420)

            F.append("<meta property=og:type content=article>")
            F.append(f'<meta property=og:title content{attribute_string(get_var_l10n(data[i_id],"title","text",lang))}>')
            F.append(f'<meta property=og:description content{attribute_string(get_var_l10n(data[i_id],"description","text",lang))}>')
            F.append("<meta property=og:site_name content=gabl.ink>")
            F.append(f"<meta property=og:url content={canonical}>")
            F.append(f"<meta property=og:image content={canonical}image.png>")
            # TODO: video_exists (sh:322–332, sh:454)
            F.append(f"<meta property=og:locale content={lang.language}_{lang.territory}>")

            F.append("<header>")
            F.append("<a href=https://gabl.ink/ id=gabldotink_logo>gabl.ink</a>")

            F.append("<ul id=lang_select>")
            for l in sorted(data[i_id]["langs"]):
                l:Language=Language.get(l)

                F.append(f"<li data-lang_select_flag={to_regional_indicators(l.region)}>")

                if l==lang:
                    F.append("<b>")
                else:
                    F.append(f"<a lang={l} href=../{str(l).lower()}/ hreflang={l}>")

                F.append(say_lang(l,"html"))

                if l==lang:
                    F.append("</b>")
                else:
                    F.append("</a>")
            F.append("</ul></header>")

            F.append(f'<h1>{msg_l10n(get_var_l10n(data[i_id],"title","html",lang),lang=lang,string="page_title_html")}</h1>')

            F.append("<nav class=nav_buttons>")

            F.append(make_nav_button("f",lang))
            F.append(make_nav_button("p",lang))
            F.append(make_nav_button("n",lang))
            F.append(make_nav_button("l",lang))

            F.append("</nav>")

            if Path(index/i_id/str(lang).lower()/"video.webm").is_file():
                F.append("<video controls poster=image.png preload=auto>")
                F.append("<source src=video.webm type=video/webm>")
                if Path(index/i_id/str(lang).lower()/"subs.vtt").is_file():
                    F.append(f"<track default src=subs.vtt srclang={lang} kind=subtitles ")
                    F.append(f'label{attribute_string(say_lang(lang,"text"))}>')
                if Path(index/i_id/str(lang).lower()/"cc.vtt").is_file():
                    F.append(f"<track src=cc.vtt srclang={lang} kind=captions ")
                    F.append(f'''label{attribute_string(f'{say_lang(lang,"text")}{msg_l10n(lang=lang,string="cc")}')}>''')
                F.append("<p>")
                F.append(msg_l10n(lang,get_var_l10n(data[data[i_id]["location"]["series"]],"title","text",lang),get_var_l10n(data[i_id],"title","text",lang),get_var_l10n(data[i_id],"title","text",lang),lang=lang,string="video_not_supported"))
                F.append("</p>")
                F.append("</video>")
            elif Path(index/i_id/str(lang).lower()/"image.png").is_file():
                F.append("<picture")
                if get_var_l10n(data[i_id],"tooltip","html",lang) is not None:
                    F.append(f' title{attribute_string(get_var_l10n(data[i_id],"tooltip","text",lang))}')
                F.append(">")
                F.append(f'<img src=image.png fetchpriority=high alt{attribute_string(msg_l10n(lang=lang,string="see_transcript"))}>')
                F.append("</picture>")

                F.append("<nav class=nav_buttons>")

            F.append(make_nav_button("f",lang))
            F.append(make_nav_button("p",lang))
            F.append(make_nav_button("n",lang))
            F.append(make_nav_button("l",lang))

            F.append("</nav>")

            F.append("<nav><details><summary>")

            # TODO: Support multiple container depths

            F.append(msg_l10n(get_var_l10n(data[data[i_id]["location"]["series"]],"title","html",lang),lang=lang,string="series_title_html"))
            F.append(msg_l10n(data[i_id]["location"]["page"],lang=lang,string="comma_page"))
            F.append(msg_l10n(get_var_l10n(data[i_id],"title","html",lang),lang=lang,string="page_title_html"))
            F.append("</summary>")
            F.append("<ol>")

            with open(Path(index/i_id/str(lang).lower()/"index_py.html"),"w",encoding="utf-8",newline='',errors="xmlcharrefreplace") as output_file:
                output_file.write(''.join(F))
