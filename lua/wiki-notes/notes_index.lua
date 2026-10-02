-- lua/wiki-notes/notes_index.lua
local util = require("wiki-notes.util")
local M = {}

local SKIP_TAGS = { archived = true, private = true }

local function is_hidden(path)
  local head = vim.fn.readfile(path, "", 30)
  for _, l in ipairs(head) do
    local t = l:match("^tags:%s*(.*)")
    if t then
      for _, tag in ipairs(vim.split(t, "[,%[%]%s]+", { trimempty = true })) do
        if SKIP_TAGS[tag] then return true end
      end
      return false
    end
  end
  return false
end

function M.update(cfg)
  local path = cfg.notes_dir .. "/index" .. cfg.ext
  if vim.fn.filereadable(path) == 0 then
    require("wiki-notes.templates").create_note(cfg, path, "index")
  end

  local cmd = string.format('rg --files -g "*.md" -- %s',
    util.shell_escape(cfg.notes_dir))
  local files = vim.fn.systemlist(cmd)
  local slugs = {}
  for _, p in ipairs(files) do
    local base = vim.fn.fnamemodify(p, ":t:r")
    if base ~= "index" and not is_hidden(p) then
      slugs[#slugs + 1] = base
    end
  end
  table.sort(slugs)

  local buf = util.find_buf(path)
  local loaded = buf and vim.api.nvim_buf_is_loaded(buf)
  local lines
  if loaded then
    lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  else
    lines = vim.fn.readfile(path)
  end

  -- Conservar frontmatter.
  local out = {}
  if lines[1] == "---" then
    for i = 2, #lines do
      if lines[i] == "---" then
        for j = 1, i do out[#out + 1] = lines[j] end
        out[#out + 1] = ""
        break
      end
    end
  end

  out[#out + 1] = "# Indice de notas"
  out[#out + 1] = ""
  for _, s in ipairs(slugs) do
    out[#out + 1] = "- [" .. s .. "]"
  end

  if loaded then
    local was_dirty = vim.bo[buf].modified
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    if not was_dirty then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
      end)
    end
  else
    vim.fn.writefile(out, path)
  end

  util.notify(string.format("Indice regenerado: %d notas", #slugs))
end

return M
