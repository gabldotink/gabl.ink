<!-- SPDX-License-Identifier: CC0-1.0 -->
# Per-region user interface

Although I don’t intend to make, say, a British English localization of content, it would be cool to allow the user to select the language variant they prefer for the UI. For example:

```json
"license": {
  "en-US": {
    "printf": "License: "
  },
  "en-GB": {
    "printf": "Licence: "
  }
}
```

Could instead be:

```json
"license": {
  "en": {
    "printf": "<span lang=en-US>License</span><span lang=en-GB>Licence</span>: "
  }
}
```

And then JavaScript could be used to show or hide `en-US` or `en-GB`.

Actually, though, I don’t know of many actual cases I have where this would be useful. The only other one I can think of is `<span lang=fr-FR>email</span><span lang=fr-CA>courriel</span>`. I haven’t quite gotten a hang of whether British English would prefer single or double quotation marks for titles, etc. It’d probably be more trouble than it’s worth there, anyway.

This would be one part of making `lang` attributes (and URLs) be shorter, as I now understand [W3C recommends](https://www.w3.org/International/questions/qa-choosing-language-tags#langsubtag).