# wiki-notes-nvim

- Wiki personal minimalista en Markdown para Neovim.

- Las notas son archivos Markdown con frontmatter YAML.
- Enlaza con `[wikilinks]`; salta y crea al vuelo.
- Renombra o borra una nota — todas las referencias se actualizan solas.
- Los tags viven en el frontmatter y se editan con un comando.
- El índice de `notes/` se regenera automáticamente.

---

## Características

| | |
|---|---|
| **Wikilinks** | `[nombre-nota]` salta al destino; si no existe, se crea desde plantilla. |
| **Backlinks** | `:WNbacklinks` lista cada nota que referencia a la actual. |
| **Refactor al renombrar** | Renombra una nota → todos los `[enlaces]` se actualizan. |
| **Borrado seguro** | Soft delete quita el texto del enlace; strong delete elimina la línea completa. |
| **Tags** | Frontmatter YAML con `:WNtag add/remove`. |
| **Índice automático** | Regenera `notes/index.md` con enlaces a cada nota visible. |
| **Helpers Markdown** | Toggle checkboxes/headings, continuación automática de listas, envolver selección en `[enlace]`. |
| **Health check** | `:checkhealth wiki-notes` / `:WNhealth`. |

---

## Requisitos

- **Neovim** ≥ 0.9
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`) — opcional, pero recomendado para backlinks e índice rápidos.
  Si no está, cae automáticamente a `grep`.

---

## Instalación

### lazy.nvim

```lua
{
  "1akaiii1/wiki-notes",
  config = function()
    require("wiki-notes").setup({
      dir = vim.fn.expand("~/wiki"),
    })
  end,
}
```

### vim-plug

```lua

vim.pack.add{
    "https://github.com/1akaiii1/wiki-notes",
 }

require("wiki-notes").setup({
      -- opciones (ver abajo)
    })
```

#### Configuración

```lua

require("wiki-notes").setup({
  dir          = vim.fn.expand("~/wiki"),
  notes_dir    = nil,   -- por defecto: <dir>/notes
  template_dir = nil,   -- por defecto: <dir>/templates

  ext               = ".md",
  default_template  = "note",
  use_ripgrep       = true,

  -- Prefija el nombre del archivo con la fecha: "02-10-2026-mi-nota"
  date_prefix = true,
  date_format = "%d-%m-%Y",

  mappings = {
    follow_link     = "<CR>",
    insert_link     = "<CR>",
    back            = "<BS>",
    toggle_checkbox = "<Leader>cx",
    toggle_heading  = "<Leader>cc",
    backlinks       = "<Leader>wb",
  },
})

```
### Sugerencia de atajos globales

```lua
local map = vim.keymap.set

map("n", "<Leader>ww", ":WNindex<CR>",             { silent = true, desc = "Wiki: índice raíz" })
map("n", "<Leader>wi", ":WNnotesindex<CR>",        { silent = true, desc = "Wiki: índice de notes" })
map("n", "<Leader>wu", ":WNnotesindexupdate<CR>",  { silent = true, desc = "Wiki: regenerar índice" })
map("n", "<Leader>wn", ":WNnew<CR>",               { silent = true, desc = "Wiki: nueva nota" })
map("n", "<Leader>wr", ":WNrename<CR>",            { silent = true, desc = "Wiki: renombrar" })
map("n", "<Leader>wx", ":WNdelete<CR>",            { silent = true, desc = "Wiki: borrar" })
map("n", "<Leader>wX", ":WNdelete!<CR>",           { silent = true, desc = "Wiki: borrar (forzar)" })
map("n", "<Leader>wf", ":WNfollow<CR>",            { silent = true, desc = "Wiki: seguir enlace" })
map("n", "<Leader>wb", ":WNbacklinks<CR>",         { silent = true, desc = "Wiki: backlinks" })
map("n", "<Leader>wh", ":WNhealth<CR>",            { silent = true, desc = "Wiki: diagnóstico" })
```
### Estructura de archivos
```
~/wiki/
├── index.md                    # manual — tú lo mantienes
├── notes/
│   ├── index.md                # autogenerado — no editar a mano
│   ├── 02-10-2026-mi-nota.md
│   └── otra-nota.md
└── templates/
    └── note.md                 # plantilla para notas nuevas

<dir>/index.md — página de inicio. Manual.

<dir>/notes/index.md — índice autogenerado. Solo edita el frontmatter.

<dir>/notes/*.md — notas creadas con :WNnew o desde un [enlace].

<dir>/templates/*.md — plantillas con placeholders {{var}}.

```
### Ejemplo templates/note.md:
```
title: {{title}}
slug: {{slug}}
created: {{date}}
tags: []
---

# {{title}}
```
