# wiki-notes

- Wiki personal minimalista en Markdown para Neovim.

---

## Requisitos

- **Neovim** ≥ 0.9
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
```

