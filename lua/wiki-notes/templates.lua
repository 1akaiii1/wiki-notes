-- lua/wiki-notes/templates.lua
local util = require("wiki-notes.util")
local M = {}
local cfg

local function substitute(text, vars)
  return (text:gsub("{{(%w+)}}", function(k) return vars[k] or "" end))
end

function M.load_template(name)
  local path = cfg.template_dir .. "/" .. name .. cfg.ext
  if vim.fn.filereadable(path) == 0 then return nil end
  return table.concat(vim.fn.readfile(path), "\n")
end

function M.create_note(c, path, title, template_name)
  c = c or cfg

  if vim.fn.filereadable(path) == 1 then
    util.notify("Nota ya existe, no se sobrescribe: "
      .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.WARN)
    return path
  end

  title = title or vim.fn.fnamemodify(path, ":t:r")
  local tmpl = M.load_template(template_name or c.default_template)
  local content
  if tmpl and tmpl ~= "" then
    content = substitute(tmpl, {
      title    = title,
      filename = vim.fn.fnamemodify(path, ":t:r"),
      slug     = util.slug(title),
      date     = os.date("%Y-%m-%d"),
      time     = os.date("%H:%M"),
      datetime = os.date("%Y-%m-%d %H:%M"),
    })
  else
    content = string.format(
      "---\ntitle: %s\nslug: %s\ncreated: %s\ntags: []\n---\n\n# %s\n\n",
      title, util.slug(title), os.date("%Y-%m-%d"), title)
  end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile(vim.split(content, "\n"), path)
  return path
end

function M.setup(config)
  cfg = config
  vim.api.nvim_create_user_command("WNnew", function(args)
    local title = args.args ~= "" and args.args or vim.fn.input("Titulo: ")
    if title == "" then return end

    local slug = util.slug(title)
    if cfg.date_prefix and slug ~= "" then
      slug = os.date(cfg.date_format or "%d-%m-%Y") .. "-" .. slug
    end

    local path = cfg.notes_dir .. "/" .. slug .. cfg.ext
    M.create_note(cfg, path, title)
    util.open_at(path)
  end, { nargs = "?", desc = "Nueva nota en notes_dir con prefijo de fecha" })
end

return M
