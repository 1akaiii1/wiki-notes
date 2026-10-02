-- lua/wiki-notes/commands.lua
local util        = require("wiki-notes.util")
local notes_index = require("wiki-notes.notes_index")
local refs        = require("wiki-notes.refs")
local M = {}

local function open_or_create(cfg, path, title)
  if vim.fn.filereadable(path) == 0 then
    require("wiki-notes.templates").create_note(cfg, path, title)
  end
  util.open_at(path)
end

local function delete_current(cfg, force)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    util.notify("Buffer sin archivo", vim.log.levels.WARN); return
  end

  local abs_wiki = vim.fn.fnamemodify(cfg.dir, ":p")
  local abs_file = vim.fn.fnamemodify(path, ":p")
  if abs_file:sub(1, #abs_wiki) ~= abs_wiki then
    util.notify("El archivo no esta dentro de la wiki", vim.log.levels.ERROR); return
  end

  local name = vim.fn.fnamemodify(path, ":t")
  local slug = vim.fn.fnamemodify(path, ":t:r")

  if name == "index" .. cfg.ext and not force then
    util.notify("index.md esta protegido. Usa :WNdelete! para forzar.",
      vim.log.levels.WARN)
    return
  end

  if not force then
    local ok = vim.fn.confirm("Borrar " .. name .. "?", "&Yes\n&No", 2)
    if ok ~= 1 then util.notify("Cancelado"); return end
  end

  local mode = force and "strong-delete" or "soft-delete"
  local n = refs.update(cfg, slug, slug, abs_file, mode)

  local buf = vim.api.nvim_get_current_buf()
  pcall(vim.api.nvim_buf_delete, buf, { force = true })
  local ok = pcall(vim.fn.delete, path)
  if not ok then
    util.notify("Error borrando: " .. name, vim.log.levels.ERROR); return
  end

  util.notify(string.format("Borrado: %s (%d archivos actualizados)", name, n))

  local abs_notes = vim.fn.fnamemodify(cfg.notes_dir, ":p")
  if abs_file:sub(1, #abs_notes) == abs_notes then
    notes_index.update(cfg)
  end
end

function M.setup(cfg)
  vim.api.nvim_create_user_command("WNindex", function()
    open_or_create(cfg, cfg.dir .. "/index" .. cfg.ext, "index")
  end, { desc = "Abrir indice de la wiki (raiz)" })

  vim.api.nvim_create_user_command("WNnotesindex", function()
    open_or_create(cfg, cfg.notes_dir .. "/index" .. cfg.ext, "index")
  end, { desc = "Abrir indice de notes/" })

  vim.api.nvim_create_user_command("WNnotesindexupdate", function()
    notes_index.update(cfg)
  end, { desc = "Regenerar notes/index.md con la lista de notas" })

  vim.api.nvim_create_user_command("WNdelete", function(args)
    delete_current(cfg, args.bang)
  end, {
    bang = true,
    desc = "Borrar la nota actual (con confirmacion; ! para forzar sin prompt)",
  })
end

return M
