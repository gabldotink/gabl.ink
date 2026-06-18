<!-- SPDX-License-Identifier: CC0-1.0 -->
# XHTML vs. HTML

Currently, we generate documents that are both valid HTML5 and XML. I basically just did this because why not.

However, doing this doesn’t yield much benefit. Any data from the HTML pages can be more easily programatically extracted from the JSON, so prioritizing XML parsers isn’t really necessary.

However, it’s also true that there aren’t big cons to doing this either, at least not that I’ve found. To see if there could potentially be a benefit to abandoning XML, I created an HTML5-only version of the X/HTML page. The original is [`01.xml.html`](./01.xml.html) in this directory, while the HTML version is [`01.html`](./01.html).

The looser syntax allowed by HTML5 allows more aggressive minification, including omitting quotation marks, omitting closing slashes for void elements, tag omission, etc.

What are the savings in this example?

* X/HTML: 13578&nbsp;bytes
* HTML5: 12784&nbsp;bytes

That’s 794&nbsp;bytes. Not _nothing_, but admittedly not much.

If I did do this, I would probably make a new localization data type for attributes. It would manage adding or omitting quotation marks, using double or single quotation marks depending on if there are the other type in the value, substituting quotation marks for character entities (`&quot;` and `&apos;`), and converting `text` to character entities (since we can’t use the `html` value).

Anyway, I can figure that out _later_!
