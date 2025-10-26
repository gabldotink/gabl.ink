<!-- SPDX-License-Identifier: CC0-1.0 -->
# Drafts (e.g. for documentation)

## The `cite` element

The `cite` element in HTML semantically represents the title of a work. Most browsers display the element’s contents in italics by default.

However, we don’t always want italics there. The standard for standalone or otherwise “major” works is italicization, but for parts or otherwise “minor” works the standard is wrapping the title in quotation marks. For websites and some other things, no formatting at all is used.

The stylesheets used on this site remove all browser-default styling, so we don’t need to worry about that.

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
