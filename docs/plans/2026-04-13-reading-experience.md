# Reading Experience Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Substituir o tema `just-the-docs` por um tema Jekyll próprio, entregando uma experiência de leitura de livro digital (e-reader) para a documentação em português sobre Java.

**Architecture:** Tema Jekyll custom (layouts próprios em `_layouts/`, includes em `_includes/`, um único stylesheet `assets/css/book.css`) servido por GitHub Pages nativo sem CI. Tipografia serif (Source Serif 4), corpo preto semibold, medida ~65ch, sem sidebar, navegação linear via footer-nav computado em Liquid a partir de `order` no front matter. Tema único claro, zero JavaScript no v1.

**Tech Stack:** Jekyll (GitHub Pages), kramdown, Rouge, Google Fonts (Source Serif 4 + Inter + JetBrains Mono), Liquid para navegação.

**Design reference:** `docs/plans/2026-04-13-tipografia-leitura-design.md` (commit `afe7ab8`).

**Preview local:** não há Gemfile. Opções:
- (preferido durante implementação) criar Gemfile mínimo — tratado na Task 1.
- (fallback) pushar para branch de preview no GitHub Pages e validar em produção.

**Natureza dos "testes":** este é um site estático sem testes automatizados. Cada task usa verificações concretas: `jekyll build` sem erros, inspeção de HTML gerado em `_site/`, e verificação visual no navegador. Seguimos o espírito de TDD adaptado: cada passo tem saída esperada verificável antes de seguir.

**Estratégia de segurança:** Fase 1 (Tasks 1–7) constrói o tema novo **em paralelo** ao just-the-docs — nada quebra, o site atual continua publicado. A troca (Fase 2) acontece num único commit atômico e reversível.

---

## Fase 1 — Andaime (site atual continua funcionando)

### Task 1: Gemfile mínimo para preview local

**Files:**
- Create: `Gemfile`
- Create: `.gitignore` (atualizar existente)

**Step 1: Criar Gemfile**

Conteúdo exato:

```ruby
source "https://rubygems.org"

# Alinha com o que o GitHub Pages usa em produção.
# Referência: https://pages.github.com/versions/
gem "github-pages", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-remote-theme"
end
```

Nota: `jekyll-remote-theme` permanece no Gemfile temporariamente para que o site atual (ainda usando `remote_theme: just-the-docs`) continue buildando localmente durante a Fase 1. Removemos em Task 8.

**Step 2: Atualizar .gitignore**

Ler `.gitignore` primeiro (atualmente contém apenas `AGENTS.md`). Adicionar:

```
AGENTS.md
Gemfile.lock
_site/
.jekyll-cache/
.sass-cache/
vendor/
.bundle/
```

**Step 3: Instalar dependências**

```bash
bundle install
```

Expected: instalação completa sem erros. Gera `Gemfile.lock` (gitignored).

Se `bundle` não existir: `gem install bundler` antes.

**Step 4: Rodar preview e validar estado atual**

```bash
bundle exec jekyll serve
```

Expected:
- Build completa sem erros.
- Site servido em `http://127.0.0.1:4000`.
- Página atual (tema cream + Fraunces) abre normal.

Parar o servidor com `Ctrl+C`.

**Step 5: Commit**

```bash
git add Gemfile .gitignore
git commit -m "add Gemfile for local preview"
```

---

### Task 2: CSS base — reset, tokens, tipografia fundacional

**Files:**
- Create: `assets/css/book.css`

**Step 1: Criar `assets/css/book.css`**

Conteúdo exato:

```css
/* ============================================================
   book.css — tema próprio, e-reader digital-first
   ============================================================ */

/* --- Reset mínimo --- */
*, *::before, *::after { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body { margin: 0; }
img, svg { max-width: 100%; height: auto; display: block; }
a { color: inherit; }

/* --- Tokens de tema --- */
:root {
  /* Cor */
  --ink:        #000000;
  --ink-soft:   #2a2a2a;
  --ink-muted:  #6b6b6b;
  --paper:      #fafaf7;
  --rule:       #e6e2da;
  --link:       #0b5fb0;
  --link-hover: #083f75;
  --mark:       #fff3a8;
  --code-bg:    #f1ede4;
  --code-ink:   #1a1a1a;

  /* Tipografia */
  --ff-serif: "Source Serif 4", "Source Serif Pro", Georgia, serif;
  --ff-sans:  "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --ff-mono:  "JetBrains Mono", "SFMono-Regular", Menlo, Consolas, monospace;

  --fs-xs:    0.75rem;
  --fs-sm:    0.875rem;
  --fs-base:  1.0625rem;
  --fs-lg:    1.25rem;
  --fs-xl:    1.5rem;
  --fs-2xl:   2.25rem;
  --fs-3xl:   clamp(2.5rem, 5vw, 3.5rem);

  --lh-body:  1.65;
  --lh-tight: 1.2;

  --fw-body:  600;   /* semibold — decisão do autor */
  --fw-head:  700;

  --measure:  38rem;
  --space-flow: 1.2em;
}

html {
  font-size: 18px;
  color-scheme: light;
}

body {
  background: var(--paper);
  color: var(--ink);
  font-family: var(--ff-serif);
  font-size: var(--fs-base);
  font-weight: var(--fw-body);
  line-height: var(--lh-body);
  font-feature-settings: "kern", "liga", "onum";
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  hyphens: auto;
}

/* --- Skip link --- */
.skip-link {
  position: absolute;
  left: -9999px;
  top: 0;
  background: var(--ink);
  color: var(--paper);
  padding: 0.5rem 1rem;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  z-index: 100;
}
.skip-link:focus { left: 0; }

/* --- Foco visível --- */
:focus-visible {
  outline: 2px solid var(--link);
  outline-offset: 3px;
  border-radius: 3px;
}

/* --- Redução de movimento --- */
@media (prefers-reduced-motion: reduce) {
  * { transition-duration: 0ms !important; animation-duration: 0ms !important; }
}
```

**Step 2: Verificar que o arquivo é sintaticamente válido**

```bash
# Jekyll não valida CSS diretamente, mas podemos rodar um build rápido
# e inspecionar que o asset foi copiado.
bundle exec jekyll build
ls _site/assets/css/
```

Expected: `book.css` e `custom.css` ambos listados em `_site/assets/css/`. Build sem erros.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "add book.css with design tokens and typography base"
```

---

### Task 3: `_includes/head.html` — `<head>` completo

**Files:**
- Create: `_includes/head.html`

**Step 1: Criar `_includes/head.html`**

Conteúdo exato:

```html
<!DOCTYPE html>
<html lang="{{ site.lang | default: 'pt-BR' }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">

  <title>{% if page.title and page.layout != 'toc' %}{{ page.number }} {{ page.title }} · {{ site.title }}{% else %}{{ site.title }} · {{ site.author }}{% endif %}</title>
  {% if page.lede or site.description %}
  <meta name="description" content="{{ page.lede | default: site.description }}">
  {% endif %}

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,600&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="{{ '/assets/css/book.css' | relative_url }}">
</head>
```

Nota sobre fontes: Source Serif 4 com variação `opsz` (optical size) no `0,8..60,...` serve desde 8pt até 60pt numa única request.

**Step 2: Verificar ausência de erros Liquid**

```bash
bundle exec jekyll build 2>&1 | grep -iE 'error|warn' || echo "build clean"
```

Expected: `build clean` (o include ainda não é referenciado por nenhum layout, mas não gera erro sozinho).

**Step 3: Commit**

```bash
git add _includes/head.html
git commit -m "add head include with fonts and stylesheet"
```

---

### Task 4: Includes restantes — header, footer-nav, footer

**Files:**
- Create: `_includes/header.html`
- Create: `_includes/footer-nav.html`
- Create: `_includes/footer.html`

**Step 1: Criar `_includes/header.html`**

```html
<header class="site-header">
  <div class="site-header-inner">
    <a class="site-id" href="{{ '/' | relative_url }}">
      <span class="site-title">{{ site.title }}</span>
      <span class="site-sep">·</span>
      <span class="site-author">{{ site.author }}</span>
    </a>
    <nav class="site-nav">
      <a href="{{ '/' | relative_url }}">Sumário</a>
    </nav>
  </div>
</header>
```

**Step 2: Criar `_includes/footer-nav.html`**

```html
{% assign chapters = site.pages | where: "layout", "chapter" | sort: "order" %}
{% assign current_idx = -1 %}
{% for ch in chapters %}
  {% if ch.order == page.order %}
    {% assign current_idx = forloop.index0 %}
    {% break %}
  {% endif %}
{% endfor %}
{% if current_idx > -1 %}
  {% assign prev_idx = current_idx | minus: 1 %}
  {% assign next_idx = current_idx | plus: 1 %}
  {% assign prev_page = chapters[prev_idx] %}
  {% assign next_page = chapters[next_idx] %}

  <nav class="footer-nav" aria-label="Navegação entre seções">
    <div class="footer-nav-slot footer-nav-prev">
      {% if prev_idx >= 0 and prev_page %}
        <a href="{{ prev_page.url | relative_url }}">
          <span class="footer-nav-arrow" aria-hidden="true">←</span>
          <span class="footer-nav-num">{{ prev_page.number }}</span>
          <span class="footer-nav-title">{{ prev_page.title }}</span>
        </a>
      {% endif %}
    </div>
    <div class="footer-nav-slot footer-nav-next">
      {% if next_page %}
        <a href="{{ next_page.url | relative_url }}">
          <span class="footer-nav-num">{{ next_page.number }}</span>
          <span class="footer-nav-title">{{ next_page.title }}</span>
          <span class="footer-nav-arrow" aria-hidden="true">→</span>
        </a>
      {% endif %}
    </div>
  </nav>
{% endif %}
```

**Step 3: Criar `_includes/footer.html`**

```html
<footer class="site-footer">
  <div class="site-footer-inner">
    <p>{{ site.author }} · <a href="{{ '/' | relative_url }}">Sumário</a></p>
  </div>
</footer>
```

**Step 4: Verificar build**

```bash
bundle exec jekyll build 2>&1 | grep -iE 'error|warn' || echo "build clean"
```

Expected: `build clean`.

**Step 5: Commit**

```bash
git add _includes/header.html _includes/footer-nav.html _includes/footer.html
git commit -m "add header, footer and footer-nav includes"
```

---

### Task 5: Layout `default.html`

**Files:**
- Create: `_layouts/default.html`

**Step 1: Criar `_layouts/default.html`**

```html
{% include head.html %}
<body>
  <a class="skip-link" href="#content">Pular para o conteúdo</a>
  {% include header.html %}
  <main id="content" class="book-main">
    {{ content }}
  </main>
  {% include footer.html %}
</body>
</html>
```

**Step 2: Verificar build**

```bash
bundle exec jekyll build 2>&1 | grep -iE 'error|warn' || echo "build clean"
```

Expected: `build clean`.

Nota: o layout existe mas nenhuma página ainda o usa — o tema just-the-docs (também chamado `default`) está sendo priorizado pelo Jekyll via tema remoto. Como temos nosso próprio `_layouts/default.html`, ele **sobrescreve** o do tema. Isso significa que **a partir deste commit o site visualmente pode quebrar até a Task 7 completar**. Se for um problema (o site está sendo acessado por leitores reais durante o trabalho), inverter: nomear este layout `book-default.html` temporariamente e renomear para `default.html` na Task 8.

**Decisão explícita antes do commit:** se quiser zero downtime durante implementação, renomear para `book-default.html` aqui e usar esse nome na Task 6. Registrar a escolha em commit message.

**Step 3: Commit**

```bash
git add _layouts/default.html
git commit -m "add default layout (HTML skeleton with header/footer)"
```

---

### Task 6: Layout `chapter.html`

**Files:**
- Create: `_layouts/chapter.html`

**Step 1: Criar `_layouts/chapter.html`**

```html
---
layout: default
---
<article class="chapter">
  <header class="chapter-header">
    {% if page.number %}
      <p class="chapter-eyebrow">{{ page.number }}</p>
    {% endif %}
    <h1 class="chapter-title">{{ page.title }}</h1>
  </header>

  <div class="chapter-body">
    {{ content }}
  </div>
</article>

{% include footer-nav.html %}
```

Nota: o `{{ content }}` já chega com o Markdown renderizado em HTML pelo kramdown. As headings dentro (`##`, `###` etc.) usam os estilos do `book.css`.

**Step 2: Verificar build**

```bash
bundle exec jekyll build 2>&1 | grep -iE 'error|warn' || echo "build clean"
```

Expected: `build clean`.

**Step 3: Commit**

```bash
git add _layouts/chapter.html
git commit -m "add chapter layout with eyebrow, title and footer-nav"
```

---

### Task 7: Layout `toc.html`

**Files:**
- Create: `_layouts/toc.html`

**Step 1: Criar `_layouts/toc.html`**

```html
---
layout: default
---
{% assign chapters = site.pages | where: "layout", "chapter" | sort: "order" %}

<section class="book-cover">
  <p class="book-cover-eyebrow">{{ site.author }}</p>
  <h1 class="book-cover-title">{{ site.title }}</h1>
  {% if site.description %}
    <p class="book-cover-lede">{{ site.description }}</p>
  {% endif %}
</section>

<nav class="toc" aria-label="Sumário">
  <ol class="toc-list">
    {% for ch in chapters %}
      {% assign depth = ch.number | split: "." | size %}
      <li class="toc-item toc-depth-{{ depth }}">
        <a href="{{ ch.url | relative_url }}">
          <span class="toc-num">{{ ch.number }}</span>
          <span class="toc-title">{{ ch.title }}</span>
        </a>
      </li>
    {% endfor %}
  </ol>
</nav>
```

**Step 2: Verificar build**

```bash
bundle exec jekyll build 2>&1 | grep -iE 'error|warn' || echo "build clean"
```

Expected: `build clean`. O TOC ainda vai listar zero capítulos enquanto nenhuma página tiver `layout: chapter`. Isso é ok — validamos em Task 9.

**Step 3: Commit**

```bash
git add _layouts/toc.html
git commit -m "add toc layout for book index"
```

---

## Fase 2 — Troca do tema

### Task 8: Atualizar `_config.yml`

**Files:**
- Modify: `_config.yml`

**Step 1: Ler o estado atual**

Conteúdo atual:

```yaml
title: Java
author: Estevão Dias
description: Aprenda a programar em Java usando a versão JDK 21
remote_theme: just-the-docs/just-the-docs
search_enabled: true
custom_css:
  - custom

# Configurações de URL para o GitHub Pages
baseurl: ""
url: "https://estevaodias.com"
```

**Step 2: Substituir pelo novo**

Conteúdo novo:

```yaml
title: Java
author: Estevão Dias
description: Aprenda a programar em Java usando a versão JDK 21
lang: pt-BR

baseurl: ""
url: "https://estevaodias.com"

markdown: kramdown
highlighter: rouge
kramdown:
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    css_class: "hl"
    block:
      line_numbers: false

exclude:
  - Gemfile
  - Gemfile.lock
  - vendor
  - docs
  - README.md
  - CLAUDE.md
  - AGENTS.md
```

Removido: `remote_theme`, `search_enabled`, `custom_css`.
Adicionado: `lang`, config de kramdown/Rouge, `exclude` (para que `docs/plans/*` não seja publicado, e arquivos meta também).

**Step 3: Remover `jekyll-remote-theme` do Gemfile**

Editar `Gemfile`, remover o bloco:

```ruby
group :jekyll_plugins do
  gem "jekyll-remote-theme"
end
```

Deixa só:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
```

**Step 4: Re-instalar dependências**

```bash
bundle install
```

Expected: `jekyll-remote-theme` removido dos gems ativos.

**Step 5: Build e inspeção**

```bash
bundle exec jekyll build
```

Expected:
- Build termina sem erros.
- `_site/index.html` agora usa nosso `_layouts/default.html` (sem HTML do just-the-docs).
- Páginas em `100/` ainda usam `layout: default` no front matter, então agora também usam nosso layout — mas elas **não** têm os campos `number`/`order` ainda, então o eyebrow fica vazio e o sumário fica vazio. Isso é esperado; próxima task conserta.

Validação rápida:

```bash
grep -c 'just-the-docs' _site/index.html || echo "no just-the-docs references"
```

Expected: `no just-the-docs references`.

**Step 6: Commit**

```bash
git add _config.yml Gemfile
git commit -m "switch from just-the-docs to custom Jekyll theme"
```

---

### Task 9: Migrar front matter das 40 páginas em `100/` (automação + revisão manual)

**Files:**
- Modify: todos os 40 arquivos em `100/`
- Create: `scripts/migrate-frontmatter.rb` (script one-shot, pode ser deletado depois)

**Step 1: Entender a ambiguidade conhecida**

Das 40 páginas, 7 têm prefixo `"1 "` (espaço, sem ponto) no filename — claramente inconsistente. Antes de rodar o script, o autor precisa decidir o `number` correto para cada uma. Lista exata:

```
1 Classes como blocos fundamentais.md              → número "1" (raiz do capítulo)
1 String é um objeto, não um tipo primitivo.md     → ? (precisa decisão)
1 Tamanhos dos tipos numéricos primitivos.md       → ? (precisa decisão)
1 Tipos de dados em Java.md                        → ? (precisa decisão)
1 Tipos inteiros.md                                → ? (precisa decisão)
1 Tipos numéricos com sinal.md                     → ? (precisa decisão)
1 Tipos primitivos não são objetos.md              → ? (precisa decisão)
```

**Step 2: Autor preenche o mapeamento**

Criar um arquivo temporário `scripts/renumber.txt` com o formato `<número>|<filename>`:

```
1|1 Classes como blocos fundamentais.md
1.X.Y|1 String é um objeto, não um tipo primitivo.md
...
```

Onde `1.X.Y` é o número de verdade definido pelo autor. Revisar o arquivo antes de prosseguir.

**Step 3: Criar o script de migração**

Criar `scripts/migrate-frontmatter.rb`:

```ruby
#!/usr/bin/env ruby
# Migra front matter das páginas em 100/ para o novo schema:
#   layout: chapter
#   number: "x.y.z"
#   order: <inteiro computado do number>
#   title: "título sem prefixo numérico"
#
# Uso: ruby scripts/migrate-frontmatter.rb

require "yaml"

PAGES_DIR = "100"
RENUMBER_FILE = "scripts/renumber.txt"

# Carrega o mapeamento filename → número (para arquivos ambíguos)
overrides = {}
if File.exist?(RENUMBER_FILE)
  File.read(RENUMBER_FILE).each_line do |line|
    next if line.strip.empty? || line.strip.start_with?("#")
    number, filename = line.strip.split("|", 2)
    overrides[filename] = number
  end
end

# Calcula `order` a partir do number dotted
# "1"         → 1_00_00_00 = 1000000
# "1.1"       → 1_01_00_00 = 1010000
# "1.1.1"     → 1_01_01_00 = 1010100
# "1.10.1.2"  → 1_10_01_02 = 1100102
def compute_order(number)
  parts = number.split(".").map(&:to_i)
  parts += [0] * (4 - parts.size) if parts.size < 4
  raise "number has more than 4 levels: #{number}" if parts.size > 4
  parts.each { |p| raise "component > 99: #{number}" if p > 99 }
  parts[0] * 1_000_000 + parts[1] * 10_000 + parts[2] * 100 + parts[3]
end

# Para filenames com prefixo dotted (ex.: "1.1.1 Foo.md"), extrai número + título
# Para filenames "1 Foo.md" (prefixo solto, ambíguo), lê do override
def extract_number_and_title(filename, overrides)
  base = filename.sub(/\.md\z/, "")
  m = base.match(/\A(\d+(?:\.\d+)+)\s+(.+)\z/)
  if m
    [m[1], m[2]]
  elsif base.match?(/\A\d+\s+/)
    # prefixo solto tipo "1 Foo" — exige override
    number = overrides[filename]
    raise "missing override for ambiguous filename: #{filename}" unless number
    title = base.sub(/\A\d+\s+/, "")
    [number, title]
  else
    raise "cannot parse: #{filename}"
  end
end

Dir.glob("#{PAGES_DIR}/*.md").sort.each do |path|
  filename = File.basename(path)
  content = File.read(path)

  # Separa front matter existente (se houver) do corpo
  if content.start_with?("---\n")
    parts = content.split(/^---\s*$/, 3)
    # parts = ["", "<yaml>", "<body>"]
    body = parts[2].sub(/\A\n/, "")
  else
    body = content
  end

  number, title = extract_number_and_title(filename, overrides)
  order = compute_order(number)

  new_frontmatter = {
    "layout" => "chapter",
    "order"  => order,
    "number" => number,
    "title"  => title,
  }

  new_content = "---\n#{new_frontmatter.to_yaml.sub(/\A---\n/, '')}---\n\n#{body}"
  File.write(path, new_content)
  puts "migrated: #{filename} → #{number} (order #{order})"
end

puts "\nDone. Review diffs with: git diff --stat 100/"
```

**Step 4: Rodar o script**

```bash
mkdir -p scripts
# criar scripts/renumber.txt com o mapeamento (Step 2)
# criar scripts/migrate-frontmatter.rb (Step 3)
ruby scripts/migrate-frontmatter.rb
```

Expected: 40 linhas `migrated: ...` impressas. Nenhum erro.

**Step 5: Revisar diff**

```bash
git diff --stat 100/
git diff 100/ | head -60
```

Verificar manualmente:
- Todo arquivo tem front matter com `layout: chapter`, `order`, `number`, `title`.
- `title` não contém mais o prefixo numérico.
- Arquivos que tinham frontmatter antigo (com `nav_order`, `has_children`) perderam esses campos.

**Step 6: Build e verificar sumário**

```bash
bundle exec jekyll build
```

Abrir `_site/index.html` (localmente) ou rodar `bundle exec jekyll serve` e navegar para `http://127.0.0.1:4000/`.

Expected:
- Sumário lista os 40 itens ordenados corretamente (1, 1.1, 1.1.1, 1.1.2, ..., 1.2, 1.3, ..., 1.10, 1.10.1, ..., 1.11, etc.).
- Nenhum item duplicado ou fora de ordem.

Se algum item aparecer fora de ordem, revisar o `renumber.txt` e re-rodar o script.

**Step 7: Commit**

```bash
git add 100/ scripts/
git commit -m "migrate 100/ front matter to chapter layout with order/number/title"
```

---

### Task 10: Migrar `index.md` para `layout: toc`

**Files:**
- Modify: `index.md`

**Step 1: Ler estado atual**

Atual:

```markdown
## Sumário

- [Fundamentos](100/1%20Classes%20como%20blocos%20fundamentais)
- [Criando objetos para usar uma classe](100/1.2%20Criando%20objetos%20para%20usar%20uma%20classe)
```

**Step 2: Substituir por**

```markdown
---
layout: toc
---
```

(Corpo vazio. O layout `toc.html` gera o conteúdo a partir de `site.pages`.)

**Step 3: Build**

```bash
bundle exec jekyll build
```

Expected: `_site/index.html` renderiza o cover + `<ol>` com 40 itens.

**Step 4: Verificar visualmente**

```bash
bundle exec jekyll serve
# abrir http://127.0.0.1:4000/
```

Expected: página inicial mostra cover de livro com título, autor, lede; abaixo, sumário numerado em duas colunas (número / título) ordenado corretamente. Clicar num item leva ao capítulo.

**Step 5: Commit**

```bash
git add index.md
git commit -m "migrate index to toc layout"
```

---

## Fase 3 — Estilização visual completa

### Task 11: CSS — layout, header, main, footer

**Files:**
- Modify: `assets/css/book.css` (append)

**Step 1: Adicionar ao final de `assets/css/book.css`**

```css
/* ============================================================
   Layout
   ============================================================ */

.book-main {
  max-width: min(100% - 2rem, var(--measure));
  margin: 0 auto;
  padding: 4rem 0 6rem;
}

/* Ritmo vertical */
.book-main > * + *,
.chapter-body > * + * {
  margin-top: var(--space-flow);
}

/* ============================================================
   Header
   ============================================================ */

.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  background: var(--paper);
  border-bottom: 1px solid var(--rule);
}

.site-header-inner {
  max-width: min(100% - 2rem, var(--measure));
  margin: 0 auto;
  padding: 0.875rem 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  font-weight: 500;
}

.site-id {
  text-decoration: none;
  color: var(--ink-soft);
}

.site-id:hover { color: var(--ink); }

.site-sep {
  margin: 0 0.35em;
  color: var(--ink-muted);
}

.site-nav a {
  text-decoration: none;
  color: var(--ink-soft);
}

.site-nav a:hover { color: var(--ink); }

/* ============================================================
   Footer
   ============================================================ */

.site-footer {
  border-top: 1px solid var(--rule);
  padding: 2rem 0;
  margin-top: 6rem;
}

.site-footer-inner {
  max-width: min(100% - 2rem, var(--measure));
  margin: 0 auto;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  color: var(--ink-muted);
}

.site-footer a { color: var(--ink-soft); }
.site-footer a:hover { color: var(--link); }
```

**Step 2: Verificar build e visual**

```bash
bundle exec jekyll serve
```

Abrir qualquer página de capítulo. Expected:
- Header fino no topo, sticky.
- Margens laterais confortáveis.
- Largura do conteúdo limitada a ~65ch.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "style header, main and footer layout"
```

---

### Task 12: CSS — tipografia do capítulo (eyebrow, h1, headings internas, parágrafo)

**Files:**
- Modify: `assets/css/book.css` (append)

**Step 1: Adicionar**

```css
/* ============================================================
   Capítulo
   ============================================================ */

.chapter-header {
  margin-bottom: 2.5rem;
}

.chapter-eyebrow {
  margin: 0;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  font-weight: 500;
  color: var(--ink-muted);
  letter-spacing: 0.02em;
}

.chapter-title {
  margin: 0.25rem 0 0;
  font-family: var(--ff-serif);
  font-size: var(--fs-2xl);
  font-weight: var(--fw-head);
  line-height: var(--lh-tight);
  color: var(--ink);
  text-wrap: balance;
}

/* Headings dentro do corpo do capítulo */
.chapter-body h2 {
  font-family: var(--ff-serif);
  font-size: var(--fs-xl);
  font-weight: var(--fw-head);
  line-height: var(--lh-tight);
  margin-top: 2.5em;
  text-wrap: balance;
}

.chapter-body h3 {
  font-family: var(--ff-serif);
  font-size: var(--fs-lg);
  font-weight: var(--fw-head);
  line-height: var(--lh-tight);
  margin-top: 2em;
  text-wrap: balance;
}

/* Compatibilidade com padrão existente: "### **Texto**" — anula o bold duplicado */
.chapter-body h3 > strong:only-child {
  font-weight: inherit;
}

.chapter-body p {
  text-wrap: pretty;
}

.chapter-body ul,
.chapter-body ol {
  padding-left: 1.5em;
}

.chapter-body li + li {
  margin-top: 0.4em;
}

.chapter-body blockquote {
  margin: 0;
  padding-left: 1rem;
  border-left: 2px solid var(--rule);
  color: var(--ink-soft);
}

.chapter-body a {
  color: var(--link);
  text-decoration-thickness: 1px;
  text-underline-offset: 0.15em;
}

.chapter-body a:hover {
  color: var(--link-hover);
}
```

**Step 2: Verificar visualmente**

Abrir uma página com `### **Exemplo conceitual**`. Expected:
- h1 grande em serif, peso 700.
- Eyebrow com o `number` acima do h1.
- h3 em serif peso 700, sem duplicação de bold do `<strong>` interno.
- Corpo em serif preto peso 600, medida limitada.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "style chapter typography (eyebrow, title, headings, body)"
```

---

### Task 13: CSS — código (inline e bloco) + syntax highlight

**Files:**
- Modify: `assets/css/book.css` (append)

**Step 1: Adicionar**

```css
/* ============================================================
   Código
   ============================================================ */

code, pre {
  font-family: var(--ff-mono);
  font-feature-settings: "calt", "liga" 0;
}

/* inline */
.chapter-body code {
  font-size: 0.92em;
  padding: 0.05em 0.35em;
  background: var(--code-bg);
  border-radius: 3px;
}

.chapter-body pre {
  margin: 1.5em 0;
  padding: 1rem 1.25rem;
  background: var(--code-bg);
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.95rem;
  line-height: 1.55;
  color: var(--code-ink);
  font-weight: 400;
}

.chapter-body pre code {
  background: transparent;
  padding: 0;
  font-size: inherit;
  border-radius: 0;
}

/* Bloco estoura medida em telas largas */
@media (min-width: 50rem) {
  .chapter-body pre {
    margin-left: -2rem;
    margin-right: -2rem;
  }
}

/* Syntax highlight — Rouge (classes .hl) */
.hl .k, .hl .kt, .hl .kd, .hl .kn { font-weight: 700; }         /* keywords e tipos */
.hl .nc, .hl .nn                   { color: var(--link); }       /* classes e namespaces */
.hl .s, .hl .s1, .hl .s2,
.hl .sc, .hl .sb, .hl .sh          { color: #7a3e00; font-style: italic; }  /* strings */
.hl .mi, .hl .mf, .hl .mh,
.hl .mo                            { color: #7a3e00; }            /* números */
.hl .c, .hl .c1, .hl .cm, .hl .cp,
.hl .cs, .hl .cd                   { color: var(--ink-muted); font-style: italic; }  /* comentários */
/* qualquer outra classe .hl .* herda --code-ink naturalmente */
```

**Step 2: Verificar visualmente**

Abrir uma página com bloco Java (ex.: `1.1 Objetos como instâncias de uma classe`). Expected:
- Bloco de código com fundo bege claro (`--code-bg`), border-radius suave.
- `public`, `class`, `new`, `return` em bold.
- `User` em azul.
- `"Alice"` em marrom itálico.
- Em telas largas, bloco estoura 2rem para cada lado.
- Inline code `` `String` `` com fundo bege claro dentro do fluxo.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "style code blocks, inline code and syntax highlight"
```

---

### Task 14: CSS — footer-nav

**Files:**
- Modify: `assets/css/book.css` (append)

**Step 1: Adicionar**

```css
/* ============================================================
   Footer-nav (navegação entre seções)
   ============================================================ */

.footer-nav {
  max-width: min(100% - 2rem, var(--measure));
  margin: 5rem auto 0;
  padding-top: 2rem;
  border-top: 1px solid var(--rule);
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
}

.footer-nav-slot {
  min-height: 3rem;   /* reserva espaço mesmo quando vazio */
}

.footer-nav-next {
  text-align: right;
}

.footer-nav a {
  text-decoration: none;
  color: var(--ink);
  display: flex;
  align-items: baseline;
  gap: 0.5em;
}

.footer-nav-next a {
  justify-content: flex-end;
}

.footer-nav-num {
  color: var(--ink-muted);
  font-variant-numeric: oldstyle-nums;
}

.footer-nav-title {
  color: var(--ink);
  font-weight: 600;
}

.footer-nav a:hover .footer-nav-title {
  color: var(--link);
}

.footer-nav-arrow {
  color: var(--ink-muted);
  font-size: 1.1em;
}
```

**Step 2: Verificar visualmente**

Expected:
- Ao fim de qualquer capítulo, linha horizontal fina e duas colunas: anterior (esquerda), próximo (direita).
- Se não houver anterior (primeiro capítulo), a esquerda fica vazia mas reserva espaço.
- Navegação entre capítulos funciona clicando nas setas.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "style footer-nav between chapters"
```

---

### Task 15: CSS — sumário (cover + TOC list)

**Files:**
- Modify: `assets/css/book.css` (append)

**Step 1: Adicionar**

```css
/* ============================================================
   Sumário (index, layout: toc)
   ============================================================ */

.book-cover {
  text-align: center;
  margin: 4rem 0 5rem;
}

.book-cover-eyebrow {
  margin: 0;
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  font-weight: 500;
  color: var(--ink-muted);
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.book-cover-title {
  margin: 0.5rem 0 0.75rem;
  font-family: var(--ff-serif);
  font-size: var(--fs-3xl);
  font-weight: var(--fw-head);
  line-height: var(--lh-tight);
  color: var(--ink);
}

.book-cover-lede {
  margin: 0 auto;
  max-width: 30rem;
  font-family: var(--ff-serif);
  font-size: var(--fs-lg);
  font-weight: var(--fw-body);
  color: var(--ink-soft);
  text-wrap: balance;
}

.toc-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.toc-item + .toc-item {
  margin-top: 0.25rem;
}

.toc-item a {
  display: grid;
  grid-template-columns: 5rem 1fr;
  gap: 0.5rem;
  padding: 0.35rem 0;
  text-decoration: none;
  color: var(--ink);
}

.toc-num {
  font-family: var(--ff-sans);
  font-size: var(--fs-sm);
  font-weight: 500;
  color: var(--ink-muted);
  font-variant-numeric: oldstyle-nums;
  text-align: right;
}

.toc-title {
  font-family: var(--ff-serif);
  font-size: var(--fs-base);
  font-weight: var(--fw-body);
}

.toc-item a:hover .toc-title {
  color: var(--link);
}

/* Indentação por profundidade */
.toc-depth-2 .toc-title { padding-left: 0.75rem; }
.toc-depth-3 .toc-title { padding-left: 1.5rem; color: var(--ink-soft); }
.toc-depth-4 .toc-title { padding-left: 2.25rem; color: var(--ink-muted); font-size: var(--fs-sm); }
```

**Step 2: Verificar visualmente**

Abrir `/`. Expected:
- Cover central com autor, título grande serif, lede.
- Sumário em duas colunas (número / título), numeração alinhada à direita em oldstyle figures.
- Itens 1.1.1, 1.1.2 etc. com indentação visual sutil.

**Step 3: Commit**

```bash
git add assets/css/book.css
git commit -m "style book cover and toc list"
```

---

### Task 16: Limpeza — remover arquivos do tema anterior

**Files:**
- Delete: `assets/css/custom.css`
- Delete: `_includes/head_custom.html`

**Step 1: Confirmar que os arquivos não são mais referenciados**

```bash
grep -r 'custom.css' . --include='*.html' --include='*.md' --include='*.yml' --exclude-dir=_site --exclude-dir=.git --exclude-dir=vendor
grep -r 'head_custom' . --include='*.html' --include='*.md' --include='*.yml' --exclude-dir=_site --exclude-dir=.git --exclude-dir=vendor
```

Expected: nenhuma referência (ou só referências em docs/plans/, que são documentação).

**Step 2: Deletar**

```bash
rm assets/css/custom.css _includes/head_custom.html
```

**Step 3: Build e sanity-check**

```bash
bundle exec jekyll build
```

Expected: build sem erros; site continua funcionando.

**Step 4: Commit**

```bash
git add -u
git commit -m "remove legacy custom.css and head_custom.html"
```

---

### Task 17: Atualizar `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Reescrever `CLAUDE.md`**

Substituir completamente o conteúdo atual (que descreve o just-the-docs) pelo novo estado:

```markdown
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
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "update CLAUDE.md for new custom theme architecture"
```

---

### Task 18: Limpar scripts/ (opcional)

Se quiser remover o script de migração após confirmar que o site está correto:

**Files:**
- Delete: `scripts/`

```bash
rm -rf scripts/
git add -u
git commit -m "remove one-shot migration script"
```

Alternativa: manter `scripts/migrate-frontmatter.rb` como referência histórica e adicionar `scripts/` ao `exclude` do `_config.yml` (já está).

---

### Task 19: Verificação visual final — checklist

Após todos os commits, rodar `bundle exec jekyll serve` e validar manualmente:

- [ ] **Sumário (`/`)**: cover central, 40 itens ordenados corretamente, sem duplicatas, indentação por profundidade visível.
- [ ] **Capítulo raiz (ex.: `/100/1%20Classes%20como%20blocos%20fundamentais`)**: eyebrow "1", h1 "Classes como blocos fundamentais", corpo em serif semibold preto, bloco de código com fundo bege e highlight, footer-nav com "→ próximo".
- [ ] **Capítulo profundo (ex.: `/100/1.10.1.2%20Importa%C3%A7%C3%B5es%20n%C3%A3o%20incluem%20subpacotes`)**: eyebrow "1.10.1.2", footer-nav com anterior e próximo.
- [ ] **Largura e medida**: em tela larga (≥1200px), corpo não ultrapassa ~38rem; blocos de código se estendem um pouco além.
- [ ] **Mobile** (DevTools → iPhone SE 375px): corpo respira (margens 1rem), código com `overflow-x` funcional, footer-nav sem quebrar.
- [ ] **Header sticky**: scrollando em capítulos longos, o header permanece no topo.
- [ ] **Acessibilidade**: Tab na página move foco visível (outline azul); skip link aparece ao primeiro Tab.
- [ ] **Fontes**: Source Serif 4 aparece no corpo (sem fallback para Georgia). Conferir em DevTools → Network → Fonts.
- [ ] **Link `Sumário`** no header retorna à index.
- [ ] **prefers-reduced-motion**: ativar em DevTools; sem transições perceptíveis.
- [ ] **Contraste**: passar o `/` e um capítulo pelo axe DevTools ou WCAG contrast checker — sem falhas AA.

Se todos os itens passarem: tag versão.

```bash
git tag v1.0-reading-experience
```

Opcional: push `git push --tags`.

---

## Decisões pendentes no momento da execução

1. **`scripts/renumber.txt`** — autor precisa preencher antes da Task 9. Os 7 arquivos com prefixo `"1 "` solto precisam de `number` dotted correto.
2. **Gemfile `Gemfile.lock`** — gitignored por padrão; se o autor preferir comitar (para builds reproduzíveis), ajustar `.gitignore`.
3. **Fallback de downtime em Task 5** — se o autor quiser evitar janela com visual quebrado, nomear o layout `book-default.html` primeiro e fazer o rename final na Task 8.

---

## Execução

Plan complete and saved to `docs/plans/2026-04-13-reading-experience.md`. Two execution options:

**1. Subagent-Driven (this session)** — eu despacho um subagent fresh por task, revisa entre tasks, iteração rápida. Bom se você quer acompanhar em tempo real e validar cada commit.

**2. Parallel Session (separate)** — você abre uma nova sessão com `executing-plans`, execução em lote com checkpoints. Bom se quer me liberar desta sessão e voltar quando estiver pronto.

Qual abordagem?
