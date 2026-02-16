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

* English text uses the following style for ellipses: <code>word[&nbsp;].[&nbsp;].[&nbsp;]. word</code> (where <code>[&nbsp;]</code> is a non-breaking space), as recommended by _CMOS_. ASCII text should instead use `word... word` to prevent bad line breaks.

## Characters to use entities or escape sequences for

Several Unicode characters are invisible or easily confusable with other characters. Many languages allow the use of character entities or escape sequences to make these more obvious, or to allow data transfer in ASCII. We’re more concerned about the former.

The following characters should always be escaped if possible (not all are expected to ever be used in this way):

| Character                       | Codepoint | Name                  | HTML               | CSS     | JSON     | Control |
|---------------------------------|-----------|-----------------------|--------------------|---------|----------|---------|
| (<code>&#8;</code>)             | U+0008    | BACKSPACE             | `&#8;`             | `\8`    | `\u0008` | `\b`    |
| (<code>&Tab;</code>)            | U+0009    | CHARACTER TABULATION  | `&Tab;`            | `\9`    | `\u0009` | `\t`    |
| (<code>&NewLine;</code>)        | U+000A    | LINE FEED             | `&NewLine;`        | `\a`    | `\u000a` | `\n`    |
| (<code>&#12;</code>)            | U+000C    | FORM FEED             | `&#12;`            | `\c`    | `\u000c` | `\f`    |
| (<code>&#13;</code>)            | U+000D    | CARRIAGE RETURN       | `&#13;`            | `\d`    | `\u000d` | `\r`    |
| (<code>&nbsp;</code>)           | U+00A0    | NO-BREAK SPACE        | `&nbsp;`           | `\a0`   | `\u00a0` |         |
| (<code>&shy;</code>)            | U+00AD    | SOFT HYPHEN           | `&shy;`            | `\ad`   | `\u00ad` |         |
| (<code>&thinsp;</code>)         | U+2009    | THIN SPACE            | `&thinsp;`         | `\2009` | `\u2009` |         |
| (<code>&hairsp;</code>)         | U+200A    | HAIR SPACE            | `&hairsp;`         | `\200a` | `\u200a` |         |
| (<code>&ZeroWidthSpace;</code>) | U+200B    | ZERO WIDTH SPACE      | `&ZeroWidthSpace;` | `\200b` | `\u200b` |         |
| (<code>&zwnj;</code>)           | U+200C    | ZERO WIDTH NON-JOINER | `&zwnj;`           | `\200c` | `\u200c` |         |
| (<code>&zwj;</code>)            | U+200D    | ZERO WIDTH JOINER     | `&zwj;`            | `\200d` | `\u200d` |         |
| (<code>&#8206;</code>)          | U+200E    | LEFT-TO-RIGHT MARK    | `&#8206;`          | `\200e` | `\u200e` |         |
| _Omitted_                       | U+200F    | RIGHT-TO-LEFT MARK    | `&#8207;`          | `\200f` | `\u200f` |         |
| (<code>&#8209;</code>)          | U+2011    | NON-BREAKING HYPHEN   | `&#8209;`          | `\2011` | `\u2011` |         |
| (<code>&#8239;</code>)          | U+202F    | NARROW NO-BREAK SPACE | `&#8239;`          | `\202f` | `\u202f` |         |
| (<code>&NoBreak;</code>)        | U+2060    | WORD JOINER           | `&NoBreak;`        | `\2060` | `\u2060` |         |

### HTML/XML

All HTML in gabl.ink should also be valid XML (XHTML). Character entities (e.g. `&nbsp;` or `&#x00a0;` [<code>&nbsp;</code>]) cannot be used in XML, aside from `&amp;` (<code>&</code>), `&apos;` (`'`), `&gt;` (`>`), `&lt;` (`<`), and `&quot;` (`"`), which are included to guarantee printing all characters is possible. These should be used sparingly, however:

* `&amp;` is only necessary if the content after it could be interpreted as a character reference (i.e. followed by `[A-Za-z#]`).
* `&apos;` is only necessary inside single quotes wrapping an attribute.
* `&gt;` is only necessary if a literal `<` precedes it outside an attribute value.
* `&lt;` is only necessary outside an attribute value.

Some of those aren’t even fully true. Whatever. Point is, if it displays correctly and validates as HTML and XML, it’s fine.

### CSS

Example: for U+00A0 NO-BREAK SPACE, use `\a0` or `\00a0`. If the escape is followed by `[A-Za-z0-9]`, use <code>\a0 </code>. The space will be interpreted as part of the escape. There’s no real reason to use the alternate syntax `\0000a0`, which never requires a space but is always longer. Escapes like `\n` are not supported.

### JSON

Example: for U+00A0 NO-BREAK SPACE, use `\u00a0`. `jq -r` will interpret this and print the actual character, so you can (and should) use these for generating HTML. They still may not be used in `ascii` or `filename`, of course. Escapes like `\n` are supported.

### Markdown

You may use character entities from the HTML5 Living Standard. Prefer terminating with semicolons, even if they are optional. If an entity is not predefined, use a decimal entity (e.g. `&#160;`).

### Shell

POSIX does not define escape sequences for special characters without extensions, so they may not be used in shell scripts. Use the literal character instead. Escapes like `\n` are supported.
