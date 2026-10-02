-- lua/wiki-notes/init.lua
local M = {}

function M.setup(user_cfg)
  local cfg = require("wiki-notes.config")
  if user_cfg then
    cfg = vim.tbl_deep_extend("force", cfg, user_cfg)
  end
  cfg.notes_dir    = cfg.notes_dir    or (cfg.dir .. "/notes")
  cfg.template_dir = cfg.template_dir or (cfg.dir .. "/templates")

  for _, d in ipairs({ cfg.dir, cfg.notes_dir, cfg.template_dir }) do
    if vim.fn.isdirectory(d) == 0 then vim.fn.mkdir(d, "p") end
  end

  require("wiki-notes.commands").setup(cfg)
  require("wiki-notes.markdown").setup(cfg)
  require("wiki-notes.links").setup(cfg)
  require("wiki-notes.templates").setup(cfg)
  require("wiki-notes.rename").setup(cfg)
  require("wiki-notes.frontmatter").setup(cfg)
  require("wiki-notes.health").setup(cfg)

  M.config = cfg
end

return M
