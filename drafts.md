<!-- SPDX-License-Identifier: CC0-1.0 -->
<!-- markdownlint-disable MD033 -->
# Drafts (e.g. for documentation)

## The `i`, `em`, and `cite` elements

The `i`, `em`, and `cite` elements in <abbr title="Hypertext Markup Language">HTML</abbr> are all usually rendered by browsers in italics by default. However, they all have different semantic meanings, which should be used correctly. gabl.ink’s default <abbr title="Cascading Style Sheets">CSS</abbr> stylesheets remove italics from `cite` by default.

## The `cite` element

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

We could insert the quotation marks using CSS, but they wouldn’t appear in the <abbr title="Document Object Model">DOM</abbr>, nor would they work with copy and paste.

For titles with no styling, we just use the element by itself, because we removed the default styling earlier:

```HTML
<cite>gabl.ink</cite>
```

Embedding `cite` elements is also allowed:

```HTML
“<cite>‘<cite>Thursday</cite>’ title page</cite>”
```

In Markdown, we only use `i` and `cite` for italicized titles, since Markdown doesn’t usually support CSS and `_underscores_` usually create the `em` element.

## <i><cite>The Chicago Manual of Style</cite></i>

gabl.ink mostly defers to <i><cite>The Chicago Manual of Style</cite></i> (<i><cite><abbr>CMOS</abbr></cite></i>) as its default style guide. This includes using American English conventions. There may be some exceptions to <i><cite>CMOS</cite></i>.

## Why program in shell? Not even a reasonable one, the standard <abbr title="Portable Operating System Interface">POSIX</abbr> shell?

im dumb
