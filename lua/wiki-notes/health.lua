-- lua/wiki-notes/health.lua
local M = {}
local cfg

function M.check()
  vim.health.start("wiki-notes")

  if vim.fn.executable("rg") == 1 then
    vim.health.ok("ripgrep disponible")
  else
    vim.health.warn("ripgrep no encontrado; backlinks y busquedas usaran grep")
  end

  if not cfg then
    vim.health.warn("cfg no inicializado; corre require('wiki-notes').setup() antes")
    return
  end

  for _, d in ipairs({ cfg.dir, cfg.notes_dir, cfg.template_dir }) do
    if vim.fn.isdirectory(d) == 1 then
      vim.health.ok("directorio: " .. d)
    else
      vim.health.error("directorio inexistente: " .. d)
    end
  end
end

function M.setup(config)
  cfg = config
  vim.api.nvim_create_user_command("WNhealth", function()
    vim.cmd("checkhealth wiki-notes")
  end, { desc = "Abrir checkhealth de wiki-notes-nvim" })
end

return M
