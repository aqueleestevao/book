# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Jekyll site published via GitHub Pages at `https://estevaodias.com` (CNAME). It is a Portuguese-language (pt-BR) textbook teaching Java (JDK 21), authored by Estevão Dias. There is no application code — every change is to Markdown content, the `_config.yml`, the `_includes/` partials, or `assets/css/custom.css`.

Note: the `/init` invocation described this repo as posts about software architecture / backend engineering. That does not match the current content (`_config.yml` title is "Java", description "Aprenda a programar em Java usando a versão JDK 21"). Treat the repo as a Java textbook unless the user says otherwise.

## Build / preview

There is no `Gemfile`, no CI workflow, and no build script committed. GitHub Pages builds the site server-side using the `just-the-docs/just-the-docs` remote theme declared in `_config.yml`. Local preview therefore requires the user to install Jekyll + the remote-theme plugin themselves; do not invent a build command. If the user asks to preview locally, suggest the standard `bundle exec jekyll serve` only after confirming they have a Gemfile set up.

## Content architecture

- `index.md` is the table of contents and links manually into section pages under `100/`.
- The `100/` directory is a chapter/part folder. All content currently lives there (the repo was recently restructured — see `git status`, every Markdown file was moved from the root into `100/`).
- File names encode the navigation hierarchy as a dotted outline: `1`, `1.1`, `1.1.1`, `1.10.1.2`, etc. The numeric prefix in the filename **must** match the `title` in the front matter and the position in the outline. When adding a new sub-section, renumber siblings if needed and update any link in `index.md` or sibling pages that points to the renumbered file.
- Just-the-docs navigation is driven by YAML front matter, not by directory structure:
  ```yaml
  ---
  layout: default
  title: 1.1 Objetos como instâncias de uma classe
  nav_order: 1
  has_children: true   # only on pages that have sub-pages
  ---
  ```
  Parent/section pages (`1`, `1.1`, `1.10`, …) carry `has_children: true`. Many leaf pages in `100/` currently have **no front matter at all** — that is the existing pattern, not necessarily intentional. Before adding front matter to a leaf page, check whether neighboring leaves have it; match the local convention and ask the user if unclear.
- Page bodies follow a consistent didactic template: short prose intro → `### **Exemplo conceitual**` with a fenced code block → `### **Explicação linha a linha**` walking through the snippet line-by-line. Preserve this structure when editing or adding content.
- Code samples are fenced blocks. Java samples may use ```` ```java ```` or an unlabeled ```` ``` ```` — both appear in existing pages. Match whatever the surrounding file uses rather than reformatting.

## Theming and assets

- Theme is set via `remote_theme: just-the-docs/just-the-docs` in `_config.yml`. There is no local `_layouts/` or `_sass/` — overrides go through `_includes/head_custom.html` (currently loads Google Fonts: Fraunces, JetBrains Mono, Work Sans) and `assets/css/custom.css` (referenced as `custom_css: [custom]` in `_config.yml`).
- `search_enabled: true` is on; just-the-docs builds the index from page front matter, so pages without front matter will not be searchable or appear in the side nav.

## Conventions to respect

- All prose, headings, titles, and committed comments are in Portuguese (pt-BR). Do not translate to English unless explicitly asked.
- File names contain spaces and accented characters (e.g. `1.1.1 Referências a objetos.md`). Internal links from `index.md` and any cross-page links must URL-encode spaces as `%20` — see `index.md` for the established style.
- `AGENTS.md` is gitignored — don't commit it.
