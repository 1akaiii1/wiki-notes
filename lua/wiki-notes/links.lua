-- lua/wiki-notes/links.lua
local util      = require("wiki-notes.util")
local templates = require("wiki-notes.templates")
local M = {}
local cfg

local function link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col  = vim.api.nvim_win_get_cursor(0)[2] + 1
  local i = 1
  while true do
    local s, e, txt = line:find("%[(.-)%]", i)
    if not s then return nil end
    if col >= s and col <= e then
      return (txt:match("^%s*(.-)%s*$"))
    end
    i = e + 1
  end
end

function M.follow()
  local name = link_under_cursor()
  if not name or name == "" then
    util.notify("No hay enlace bajo el cursor", vim.log.levels.WARN); return
  end
  local path = util.resolve_note(cfg, name)
  if not path then
    util.notify("Nota no existe: " .. name, vim.log.levels.WARN); return
  end
  util.open_at(path)
end

function M.follow_or_create()
  local name = link_under_cursor()

  if name and name ~= "" then
    local path = util.resolve_note(cfg, name)
    if not path then
      local target_dir = util.create_location(cfg)
      path = target_dir .. "/" .. util.slug(name) .. cfg.ext
      templates.create_note(cfg, path, name)

      local stale = util.find_buf(path)
      if stale then
        pcall(vim.api.nvim_buf_delete, stale, { force = true })
      end
    end
    util.open_at(path)
    return
  end

  local word = vim.fn.expand("<cword>")
  if word == "" then
    util.notify("Nada que enlazar bajo el cursor", vim.log.levels.WARN); return
  end
  vim.cmd("normal! ciw[" .. word .. "] ")
end

function M.backlinks()
  local name = util.current_note_name()
  local results = util.grep_fixed("[" .. name .. "]", cfg.dir, cfg)

  local items = {}
  for _, line in ipairs(results) do
    local p = util.parse_grep_line(line)
    if p and vim.fn.fnamemodify(p.file, ":t:r") ~= name then
      table.insert(items, {
        file  = p.file,
        lnum  = p.lnum,
        label = string.format("%s:%d  %s",
          vim.fn.fnamemodify(p.file, ":t"), p.lnum,
          p.text:sub(1, 80)),
      })
    end
  end

  util.pick(
    items,
    "Backlink -> " .. name .. ":",
    function(choice) util.open_at(choice.file, choice.lnum) end,
    function(i) return i.label end)
end

function M.setup(config)
  cfg = config
  vim.api.nvim_create_user_command("WNbacklinks", M.backlinks, {})
  vim.api.nvim_create_user_command("WNfollow",    M.follow,    {})
end

return M
