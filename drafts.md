<!-- SPDX-License-Identifier: CC0-1.0 -->
<!-- markdownlint-disable MD033 -->
# Drafts (e.g. for documentation)

## The `i`, `em`, and `cite` Elements

The `i`, `em`, and `cite` elements in HTML are all usually rendered by browsers in italics by default. However, they all have different semantic meanings, which should be used correctly. gabl.ink’s default CSS stylesheets remove italics from `cite` by default.

## The `cite` Element

<!-- markdownlint-disable-next-line MD036 -->
**ignore this actually**

The `cite` element in HTML semantically represents the title of a work. Most browsers display the element’s contents in italics by default.

However, we don’t always want italics there. The standard for standalone or otherwise “major” works is italicization, but for parts or otherwise “minor” works the standard is wrapping the title in quotation marks. For websites and some other things, no formatting at all is used.

gabl.ink’s default CSS stylesheets remove all browser-default styling, so we don’t need to worry about that.

For italicized works, we explicitly place the `cite` element inside the `i` element:

```HTML
<i><cite>JoeRunner and Co.</cite></i>
```

This is a little bit dubious semantically, but it ensures that the title appears in italics for copy and paste into rich text documents. It is also consistent with what we do with quotation marks for titles. For both these reasons, we don’t just italicize with CSS for `cite`.

For works with quotation marks, we place the `cite` element inside the marks:

```HTML
“<cite>Thursday</cite>”
```

We could insert the quotation marks using CSS, but they wouldn’t appear in the DOM, nor would they work with copy and paste.

For titles with no styling, we just use the element by itself, because we removed the default styling earlier:

```HTML
<cite>gabl.ink</cite>
```

Embedding `cite` elements is also allowed:

```HTML
“<cite>‘<cite>Thursday</cite>’ title page</cite>”
```

In Markdown, we only use `i` and `cite` for italicized titles, since Markdown doesn’t usually support CSS and `_underscores_` usually create the `em` element.

## _The Chicago Manual of Style_ (_CMOS_)

gabl.ink mostly defers to _The Chicago Manual of Style_ (_CMOS_) as its default style guide. This includes using American English conventions. Already-written text, including quotations, generally does not need to be changed aside from minor typographical formatting.

### Exceptions to _CMOS_

* T.T.’s name is an initialism of his full name, so it would normally be written _TT_. However, I don’t like how that looks, so this is an exception. That’s basically the only reason.
  * When I restart _JoeRunner & Co._, I’ll make his name t.t., where _CMOS_ would allow the periods, although it would surely still make copyeditors groan for obvious reasons. Too bad, there’ll be an in-universe reason for it so they can’t do anything about it. Also, I’m the copyeditor myself anyway.

## Why program in shell? Not even a reasonable one, the standard POSIX shell?

im dumb

## CSS-Generated Quotation Marks

### The `q` Element

<!-- markdownlint-disable-next-line MD036 -->
_Note: Somewhat outdated_

The `q` element represents an inline quotation. Most browsers insert quotation marks before and after its content. However, the marks do not appear in the DOM. The HTML spec says it is incorrect to use both quotation marks in HTML and `q`, but it _is_ correct to not use `q` at all and instead use the marks.

Since this is considered “okay,” I initially wanted to do this with the `cite` element for titles that use quotation marks, but there are a few problems:

* The types of quotation marks can be defined using the `quote` property in CSS, and it even handles nesting; a value of `"“" "”" "‘" "’"` will use the first two marks first and the last two inside those. However, while a third nested quote _should_ go back to the double marks, it instead stays on the single.
* In American English, periods and commas are usually put inside quotation marks when they end, e.g. `My favorite episode is “Pilot.”` However, it would not be semantically correct to write `<cite>Pilot.</cite>`, since the period is not part of the actual title. We also can’t add the period with CSS, since it is definitely semantically important, unlike the quotation marks which are considered styling. We could do something awkward like move the CSS quotation marks to the right and move the HTML period to the left, but this is inconsistent between fonts. We could insert a period and ending mark with CSS, and then add a period with a font size of zero after it, but at that point we’re just being silly.

For these reasons, we don’t use the `q` element at all, and we put the `cite` element inside HTML quotation marks but before the period, e.g. `My favorite episode is “<cite>Pilot</cite>.”` Since we do this with quotation marks, we also consider titles being italicized to be semantically important, and use both `i` and `cite`. While just using CSS would have pros if it worked better for this use case, putting them in the HTML also has many pros.

## Pronounciations

### French

_gabl.ink_: /ˈɡabœl dɔt ink/

## Localization data types

A localized JSON value must have at least one of the `ascii`, `filename`, `text`, `html`, or `id` values. If there is no `html` value, the script’s `html` value will be set to the JSON `text` value. If there is no `text` value, the `text` value will be set to the JSON `ascii` value. It’s fine to omit one or more if they aren’t expected to be used. An `id` value is localized, but does not contain linguistic content (e.g. a URL or hashtag). If `id` exists, others should not.

### Text to ASCII

* English text uses the following style for ellipses: `word[ ].[ ].[ ]. word` (where `[ ]` is a non-breaking space), as recommended by _CMOS_. ASCII text should instead use `word... word` to prevent bad line breaks.
