
# Cheatsheet de Wiki Notes

Referencia rápida de atajos y comandos del plugin **wiki-notes-nvim**.

## Globales (cualquier buffer)

### Abrir e índices

| Atajo | Comando | Acción |
|---|---|---|
| `<Leader>ww` | `:WNindex` | Abre/crea `~/wiki/index.md` (manual) |
| `<Leader>wi` | `:WNnotesindex` | Abre/crea `~/wiki/notes/index.md` |
| `<Leader>wu` | `:WNnotesindexupdate` | Regenera `notes/index.md` |

### Crear / editar / borrar

| Atajo | Comando | Acción |
|---|---|---|
| `<Leader>wn` | `:WNnew [título]` | Nueva nota en `notes/` con prefijo de fecha |
| `<Leader>wr` | `:WNrename [nuevo]` | Renombrar nota + actualizar `[enlaces]` en toda la wiki |
| `<Leader>wx` | `:WNdelete` | Borrar nota (confirmación) |
| `<Leader>wX` | `:WNdelete!` | Borrar sin confirmar (elimina la línea entera del índice) |
| `<Leader>wa` | prompt | Añadir tag al frontmatter |
| `<Leader>wA` | prompt | Quitar tag del frontmatter |

### Navegar enlaces

| Atajo | Comando | Acción |
|---|---|---|
| `<Leader>wf` | `:WNfollow` | Seguir el enlace bajo el cursor |
| `<Leader>wb` | `:WNbacklinks` | Lista de notas que enlazan a la actual |

### Diagnóstico

| Atajo | Comando | Acción |
|---|---|---|
| `<Leader>wh` | `:WNhealth` | Verifica ripgrep y directorios |

## Dentro de una nota Markdown

| Atajo | Modo | Acción |
|---|---|---|
| `<BS>` | normal | Volver a la nota wiki anterior (filtra el jumplist) |
| `<CR>` | normal | Seguir el enlace bajo el cursor. Si no existe, lo crea |
| `<CR>` | visual | Envolver la selección en `[ ]` |
| `<CR>` | insert | Continúa listas y checkboxes automáticamente |
| `<Leader>wb` | normal | Backlinks de la nota actual |
| `<Leader>cc` | normal | Alternar `#` al inicio de la línea (heading) |
| `<Leader>cx` | normal | Alternar checkbox `- [ ]` / `- [x]` |

## Convenciones

### Nombres de archivo

- Notas nuevas: `DD-MM-YYYY-slug.md` (prefijo de fecha + slug del título).
- `index.md` reservado en `~/wiki/` y `~/wiki/notes/`.

### Enlaces

- Formato: `[texto]` sin paréntesis ni ruta.
- Se resuelven por slug: `[Mi Nota]`, `[mi-nota]` y `[MI NOTA]` apuntan al mismo archivo.
- Si el archivo no existe al pulsar `<CR>`, se crea con la plantilla en la ubicación correspondiente:
  - Enlace creado desde `~/wiki/` → se crea en `~/wiki/`
  - Enlace creado desde cualquier otra nota → se crea en `~/wiki/notes/`

