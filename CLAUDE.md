# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Jekyll site published via GitHub Pages at `https://estevaodias.com` (CNAME). It is a Portuguese-language (pt-BR) textbook teaching Java (JDK 21), authored by Estevão Dias. There is no application code — every change is to Markdown content, the `_config.yml`, the theme files under `_layouts/` / `_includes/`, or `assets/css/book.css`.

## Build / preview

`bundle install` once, then `bundle exec jekyll serve` to preview at `http://127.0.0.1:4000`. `Gemfile` pins the `github-pages` gem so local builds match production. `Gemfile.lock` is gitignored.

## Theme architecture

This repo uses a **custom Jekyll theme** living in this repo — not a remote theme. The structure is:

- `_layouts/default.html` — HTML skeleton (head, skip link, header, main, footer).
- `_layouts/chapter.html` — layout for all content pages in `100/`. Wraps `{{ content }}` in `<article class="chapter">` with an eyebrow (`page.number`) and an h1 (`page.title`), followed by the footer-nav include.
- `_layouts/toc.html` — layout for `index.md`. Generates the book's table of contents from `site.pages | where: "layout", "chapter" | sort: "order"`.
- `_includes/head.html` — `<head>` element with fonts (Source Serif 4, Inter, JetBrains Mono via Google Fonts), `<meta name="color-scheme" content="light">`, and link to `book.css`.
- `_includes/header.html` — thin sticky header with site title/author and a "Sumário" link.
- `_includes/footer-nav.html` — computes previous/next chapter via Liquid by sorting all chapter pages by their `order` field. Renders two slots (even when one is empty, to prevent layout shift).
- `_includes/footer.html` — minimal footer with author line and sumário link.
- `assets/css/book.css` — single stylesheet. Design tokens at the top (`--ink`, `--paper`, font families, scale, measure). Sections for layout, header/footer, chapter typography, code, footer-nav, TOC.

There is no JavaScript in v1.

## Content convention — front matter

Every Markdown file in `100/` uses this schema:

```yaml
---
layout: chapter
order: <integer>
number: "<x.y.z dotted>"
title: "<title without numeric prefix>"
---
```

- `order` is an integer used only for sorting (`site.pages | sort: "order"`). Computed deterministically from `number`: each dotted component occupies two decimal digits. `1` → 1000000, `1.1` → 1010000, `1.10.1.2` → 1100102. See `scripts/migrate-frontmatter.rb` (if still in the repo) for the algorithm.
- `number` is the display number shown in the eyebrow of `<h1>` and in the TOC.
- `title` is the title *without* the numeric prefix. The template renders `number` and `title` separately.

When adding a new page:
1. Pick the correct dotted `number`. If inserting mid-sequence, renumber siblings as needed.
2. Compute `order` with the rule above.
3. Write `title` without the numeric prefix.
4. No need to touch `index.md` — the TOC is generated automatically.

`index.md` is `layout: toc` with an empty body.

## Content body convention

Pages follow a didactic template: short prose → `### **Exemplo conceitual**` with a fenced code block → `### **Explicação linha a linha**` walking through the snippet. `book.css` has a rule that strips the duplicated bold from `### **...**` (it detects `h3 > strong:only-child` and resets `font-weight`). Keep the pattern when editing existing pages, but the v2 evolution is to standardize these into Liquid includes (not in scope for v1).

Code fences: both ```` ```java ```` and unlabeled ```` ``` ```` appear. Rouge (via kramdown) handles syntax highlighting regardless; the CSS in `book.css` under `.hl` styles it.

## Locale and file naming

- All prose, titles and commit messages in pt-BR (file names included — they contain spaces and accented chars).
- Internal links must URL-encode spaces as `%20`.
- `lang: pt-BR` is set site-wide in `_config.yml` so `hyphens: auto` and screen readers work correctly.

## Gitignored

- `AGENTS.md`, `Gemfile.lock`, `_site/`, `.jekyll-cache/`, `vendor/`, `.bundle/`.
