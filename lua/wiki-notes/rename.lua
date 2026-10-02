-- lua/wiki-notes/rename.lua
local util        = require("wiki-notes.util")
local notes_index = require("wiki-notes.notes_index")
local refs        = require("wiki-notes.refs")
local M = {}
local cfg

function M.rename(new_name)
  if not new_name or new_name == "" then
    util.notify("Nombre vacio", vim.log.levels.ERROR); return
  end
  local old_path = vim.api.nvim_buf_get_name(0)
  if old_path == "" then
    util.notify("Buffer sin archivo", vim.log.levels.ERROR); return
  end

  local old_name = vim.fn.fnamemodify(old_path, ":t:r")
  local dir      = vim.fn.fnamemodify(old_path, ":h")

  local new_slug = util.slug(new_name)
  if new_slug == "" then
    util.notify("Nombre invalido", vim.log.levels.ERROR); return
  end
  local new_path = dir .. "/" .. new_slug .. cfg.ext

  if vim.fn.filereadable(new_path) == 1 then
    util.notify("Ya existe: " .. new_slug, vim.log.levels.ERROR); return
  end

  vim.fn.rename(old_path, new_path)
  local n = refs.update(cfg, old_name, new_slug, new_path, "rename")

  local buf = vim.api.nvim_get_current_buf()
  local ok = pcall(vim.api.nvim_buf_set_name, buf, new_path)
  if not ok then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    util.open_at(new_path)
  else
    vim.cmd("silent! edit!")
  end

  util.notify(string.format("Renombrado %s -> %s (%d archivos actualizados)",
    old_name, new_slug, n))

  local abs_notes = vim.fn.fnamemodify(cfg.notes_dir, ":p")
  local abs_new   = vim.fn.fnamemodify(new_path, ":p")
  if abs_new:sub(1, #abs_notes) == abs_notes then
    notes_index.update(cfg)
  end
end

function M.setup(config)
  cfg = config
  vim.api.nvim_create_user_command("WNrename", function(args)
    local name = args.args ~= "" and args.args
      or vim.fn.input("Nuevo nombre: ", vim.fn.expand("%:t:r"))
    M.rename(name)
  end, { nargs = "?", desc = "Renombrar nota y actualizar enlaces" })
end

return M
