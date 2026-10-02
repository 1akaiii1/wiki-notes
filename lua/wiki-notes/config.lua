-- lua/wiki-notes/config.lua
local home = vim.fn.expand("~")

return {
  dir          = home .. "/wiki",
  notes_dir    = nil,  -- default: <dir>/notes
  template_dir = nil,  -- default: <dir>/templates
  ext          = ".md",
  default_template = "note",
  use_ripgrep  = true,

  -- Prefija el nombre del archivo con la fecha: "25-09-2026-mi-nota"
  date_prefix  = true,
  date_format  = "%d-%m-%Y",

  mappings = {
    follow_link     = "<CR>",
    insert_link     = "<CR>",
    back            = "<BS>",
    toggle_checkbox = "<Leader>cx",
    toggle_heading  = "<Leader>cc",
    backlinks       = "<Leader>wb",
  },
}
