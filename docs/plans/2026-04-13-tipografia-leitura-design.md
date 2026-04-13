# Design — Tipografia e experiência de leitura

Data: 2026-04-13
Autor: Estevão Dias (com Claude)
Status: aprovado, aguardando plano de implementação

## Objetivo

Elevar a experiência de leitura do site em `https://estevaodias.com` para algo próximo da leitura de um livro digital. O leitor-alvo é um desenvolvedor que chega a uma página via busca; quando estiver naquela página, deve sentir que está lendo um livro, não uma documentação de referência.

## Decisões de direção (restrições fixadas com o autor)

- **Reset tipográfico completo.** Sem compromisso com o visual cream/warm + Fraunces/Work Sans atual.
- **Sair do just-the-docs.** Construir um tema Jekyll próprio. O tema remoto não será consumido.
- **Referência editorial: e-reader digital-first** (Medium / Kindle / Instapaper). Não imitar papel; otimizar para leitura longa em tela.
- **Controles mínimos.** Sem toggles visíveis de tema ou tamanho de fonte. V1 entrega um único tema claro.
- **Corpo em preto puro (`#000`), peso 600 (semibold).** Decisão do autor, em desvio do padrão regular.
- **Sem JavaScript no v1.** Tudo estático via Liquid + CSS.

## Arquitetura

### Estrutura de arquivos resultante

```
_config.yml             — sem remote_theme; metadados de livro; Rouge
_layouts/
  default.html          — HTML base: head, skip-link, body
  chapter.html          — herda default; layout das páginas em 100/
  toc.html              — layout da index.md (sumário do livro)
_includes/
  head.html             — meta, fontes, CSS, color-scheme
  header.html           — faixa fina: título do livro + link Sumário
  footer-nav.html       — ← anterior · próximo → via Liquid
  footer.html           — rodapé mínimo (autoria + link sumário)
assets/
  css/
    book.css            — único stylesheet
```

### Arquivos removidos

- `remote_theme: just-the-docs/just-the-docs` em `_config.yml`
- `custom_css: [custom]` em `_config.yml`
- `search_enabled: true` em `_config.yml`
- `assets/css/custom.css` (substituído por `assets/css/book.css`)
- `_includes/head_custom.html` (mesclado em `_includes/head.html`)

### Front matter — convenção nova

Todas as páginas em `100/` passam a usar:

```yaml
---
layout: chapter
order: 110
number: "1.1"
title: "Objetos como instâncias de uma classe"
---
```

- `order`: inteiro usado exclusivamente para `sort` do footer-nav e do sumário. Função determinística do `number` (algoritmo a fechar no plano; candidato: `number` dotted com cada componente em dois dígitos → `1.1` = 10100, `1.10.1.2` = 11001_02 → 1100102, etc.).
- `number`: string dotted, como "1.1", "1.10.1.2". Exibido no eyebrow do h1 e no sumário.
- `title`: título **sem** o prefixo numérico (diferente do estado atual).

`index.md` passa a usar `layout: toc` e tem corpo vazio; o layout gera o sumário.

Páginas atualmente sem front matter ganham front matter.

### Navegação entre páginas (Liquid)

`footer-nav.html` faz:

```liquid
{% assign chapters = site.pages | where: "layout", "chapter" | sort: "order" %}
{% for ch in chapters %}
  {% if ch.order == page.order %}
    {% assign idx = forloop.index0 %}
  {% endif %}
{% endfor %}
{% assign prev = chapters[idx | minus: 1] %}
{% assign next = chapters[idx | plus: 1] %}
```

Renderiza dois slots com seta, número e título. Slot vazio mantém espaço reservado para não "pular" o layout.

## Tipografia

### Famílias

- **Corpo e títulos:** Source Serif 4 (variable, Google Fonts). Continuidade tipográfica entre corpo e hierarquia = sensação de livro. Alternativa equivalente considerada: Literata.
- **UI:** Inter (variable). Usada em header, footer-nav, eyebrow do h1, captions. Separa "interface" de "texto".
- **Código:** JetBrains Mono (mantida da escolha atual).

### Escala (modular 1.2, base 18px)

| Token        | rem                   | Uso                                    |
|--------------|-----------------------|----------------------------------------|
| `--fs-xs`    | 0.75                  | metadados, captions                    |
| `--fs-sm`    | 0.875                 | UI                                     |
| `--fs-base`  | 1.0625                | corpo (~17px desktop; 18px mobile via clamp) |
| `--fs-lg`    | 1.25                  | h3 / abertura de seção                 |
| `--fs-xl`    | 1.5                   | h2                                     |
| `--fs-2xl`  | 2.25                  | h1 de capítulo                         |
| `--fs-3xl`  | clamp(2.5, 5vw, 3.5)  | cover do sumário                       |

### Medida e ritmo

- `--measure: 38rem` (~65 caracteres). Aplicada a `main` e descendentes diretos.
- `line-height: 1.65` no corpo, `1.2` em títulos.
- Ritmo via `main > * + * { margin-top: var(--space-flow, 1.2em); }`.
- Parágrafos sem indentação; separação por espaço em branco (digital-first).

### Detalhes editoriais

- `font-feature-settings: "kern", "liga", "onum"` no corpo (oldstyle figures).
- `text-wrap: pretty` em parágrafos; `text-wrap: balance` em h1/h2.
- `hyphens: auto` com `lang="pt-BR"` no `<html>`.
- **Corpo: `color: #000`, `font-weight: 600`.** Desvio consciente do default regular, pedido do autor.

## Cor — tema único claro

```
--ink:        #000000      corpo
--ink-soft:   #2a2a2a      metadados, captions
--ink-muted:  #6b6b6b      footer-nav inativo, hints
--paper:      #fafaf7      fundo (off-white; menos fadiga que #fff)
--rule:       #e6e2da      linhas finas (header, footer-nav)
--link:       #0b5fb0      azul editorial (AA em corpo)
--link-hover: #083f75
--mark:       #fff3a8      highlight eventual
--code-bg:    #f1ede4      bloco de código (papel um passo mais escuro)
--code-ink:   #1a1a1a
```

- Sem gradientes. Sem hachura. Sem `box-shadow` decorativo.
- Fundo sólido `--paper`.
- `<meta name="color-scheme" content="light">` — mesmo em SO dark, scrollbars/form nativos seguem light.

## Layout do capítulo

```
┌────────────────────────────────────────────────────────┐
│  Java · Estevão Dias                     Sumário       │  header 56px, sticky, rule embaixo
├────────────────────────────────────────────────────────┤
│                                                        │
│          1.1 · Objetos como instâncias                 │  eyebrow (Inter .875rem --ink-muted)
│                                                        │  h1 (Source Serif 2.25rem)
│          Um objeto é uma instância...                  │  corpo Source Serif 600 #000 medida 38rem
│                                                        │
│          ┌──────────────────────────────────┐          │
│          │ User user = new User("Alice");   │          │  code block --code-bg
│          └──────────────────────────────────┘          │
│                                                        │
├────────────────────────────────────────────────────────┤
│  ← 1  Classes como blocos     1.1.1 Referências →      │  footer-nav, rule em cima
└────────────────────────────────────────────────────────┘
```

- Body = coluna única centrada, `max-width: min(100% - 2rem, 38rem)`.
- Header full-width com conteúdo interno limitado à mesma coluna.
- h1 renderizado como duas linhas: `number` como eyebrow em Inter, `title` em Source Serif.
- Sem sidebar, sem TOC lateral, sem busca no v1. Navegação em três lugares: sumário (via header), footer-nav (fim de leitura), âncoras de heading dentro da página.

## Código

### Configuração

`_config.yml`:

```yaml
markdown: kramdown
highlighter: rouge
kramdown:
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    css_class: 'hl'
    span:  { line_numbers: false }
    block: { line_numbers: false }
```

### Bloco

- Fundo `--code-bg`, padding `1rem 1.25rem`, `border-radius: 6px`.
- JetBrains Mono 0.95rem, cor `--code-ink`.
- Sem borda visível, sem sombra, sem botão de copiar (v1).
- `overflow-x: auto`; sem quebra automática.
- Bloco "estoura" a medida em até 4rem de cada lado em telas largas (margem negativa) — Java idiomático tem linhas longas e comprimir dentro de 65ch torce o código; corpo de texto permanece em 38rem.

### Syntax highlight — paleta sóbria

Três cores além do preto:

```css
.hl .k, .hl .kt       { font-weight: 700; }                        /* palavras-chave e tipos primitivos */
.hl .nc, .hl .nn      { color: #0b5fb0; }                          /* nomes de classe e namespaces */
.hl .s, .hl .s1, .hl .s2 { color: #7a3e00; font-style: italic; }    /* strings */
.hl .mi, .hl .mf      { color: #7a3e00; }                          /* números */
.hl .c, .hl .c1, .hl .cm { color: #6b6b6b; font-style: italic; }    /* comentários */
/* todo o resto: --code-ink */
```

Filosofia: destacar o que dá estrutura semântica (keyword em peso, tipo em cor, literal em cor secundária) e ignorar o resto. Oposto de IDE; coerente com livro técnico.

### Inline code

Mesma fonte mono, `font-size: 0.92em`, `padding: 0.05em 0.35em`, `background: --code-bg`, `border-radius: 3px`. Cor herdada do parágrafo.

## Sumário (`index.md`)

`layout: toc` gera o sumário a partir de `site.pages | where: layout == chapter | sort: order`:

```
                    Estevão Dias
                       Java
             Aprenda a programar em Java
                usando a versão JDK 21

   1       Classes como blocos fundamentais
   1.1     Objetos como instâncias de uma classe
   1.1.1   Referências a objetos
   1.1.2   Memória e Heap no Java
   ...
```

- `<ol>` com `display: grid; grid-template-columns: 5rem 1fr`.
- Número em Inter, oldstyle figures, `--ink-muted`.
- Título em Source Serif, `--ink`.
- Indentação visual sutil por profundidade (contada pelos `.` em `number`).

## Padrão didático "Exemplo conceitual / Explicação linha a linha"

### V1 — só CSS, não mexer em conteúdo

Reconhecer a forma atual (`### **Exemplo conceitual**`) e estilizar para funcionar como _separador de cena_:

- h3 em Source Serif 1.25rem, peso 700, margem-topo 2em.
- Regra que detecta `<strong>` como filho único de `<h3>` e remove o peso extra, para evitar bold duplicado.

Zero alteração no Markdown. 40 páginas intocadas.

### V2 (evolução, fora do escopo v1) — containers Liquid

Criar includes `example.html` e `walkthrough.html` que renderizam:

- `example.html` → `<figure class="example">` com legenda "Exemplo".
- `walkthrough.html` → `<dl>` onde `<dt>` é snippet e `<dd>` é parágrafo; linha fina vertical à esquerda conectando snippet à explicação.

Visual-alvo do walkthrough:

```
│  User user = new User("Alice");
│  ├── Cria um objeto da classe User...
│
│  User user2 = new User("Bob");
│  ├── Cria um segundo objeto...
```

Requer migrar ~40 arquivos para sintaxe nova. Tratado como task separada, depois do v1 estar no ar.

## Acessibilidade

- `<html lang="pt-BR">`.
- Skip link como primeiro elemento do body; visível apenas em foco; aponta para `<main id="content">`.
- `:focus-visible` com outline de 2px em `--link`, offset 3px. Sem `outline: none` em lugar nenhum.
- Headings com `id` via default do kramdown. Âncoras `#` não aparecem visualmente no v1.
- Contraste: `#000` em `#fafaf7` ≈ 19.8:1 (AAA). `#0b5fb0` em `#fafaf7` ≈ 6.9:1 (AA em 1.0625rem).
- `prefers-reduced-motion: reduce` → transições de hover em 0ms.
- Remover o `@keyframes rise` atual (sem animação de entrada de página).
- `<meta name="color-scheme" content="light">`.

## Descomissionamento do just-the-docs — ordem

1. Criar layouts, includes, `book.css` em paralelo ao tema atual (nada quebra).
2. Trocar `_config.yml`: remover `remote_theme`, `custom_css`, `search_enabled`; adicionar Rouge; adicionar `lang: pt-BR`.
3. Migrar front matter das 40 páginas em `100/`:
   - `layout: default` → `layout: chapter`
   - remover `nav_order`, `has_children`
   - adicionar `order`, `number`, `title` (sem prefixo numérico)
   - páginas sem front matter ganham.
4. `index.md` → `layout: toc`, corpo vazio.
5. Apagar `assets/css/custom.css` e `_includes/head_custom.html`.
6. Atualizar `CLAUDE.md` para a nova arquitetura.

Item (3) é mecânico: filename → `number` e `title` por regex; `order` por função determinística do `number`. Candidato: script one-shot versus commit manual em lote — decisão no plano de implementação.

## Não-objetivos do v1

- Tema escuro ou sépia.
- Qualquer toggle (fonte, tamanho, tema).
- Botão de copiar em bloco de código.
- Busca interna.
- Sidebar ou TOC lateral.
- Migração para Astro/11ty/outro gerador.
- Containers Liquid para "Exemplo / Explicação" (v2).
- Self-host de fontes (v2 opcional).

## Riscos e pontos abertos

- **Ordenação determinística a partir de `number` dotted.** Algoritmo exato a ser fechado no plano; precisa ordenar `1`, `1.1`, `1.1.1`, `1.10.1.2`, `1.11`, etc. corretamente. Solução provável: pad por componente (`01.01.00.00` em vez de `1.1`) ou inteiro concatenado com padding fixo.
- **Font weight 600 em corpo.** Pode ficar "pesado demais" dependendo da calibração de tela. Decisão do autor; se na prática incomodar, tem saída fácil via `--fw-body` como CSS variable.
- **Code blocks estourando a medida com margem negativa.** Precisa testar em mobile; fallback para `overflow-x: auto` dentro da coluna de 38rem quando viewport < ~44rem.
- **Dependência de Google Fonts em runtime.** V1 aceita; v2 pode self-hospedar para performance e privacidade.
