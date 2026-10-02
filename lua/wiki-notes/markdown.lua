-- lua/wiki-notes/markdown.lua
local links = require("wiki-notes.links")
local M = {}

function M.setup(cfg)
  local maps = cfg.mappings

  local function wiki_back()
    local abs_wiki = vim.fn.fnamemodify(cfg.dir, ":p")
    local jl, idx = unpack(vim.fn.getjumplist())
    if idx == 0 then return end

    for i = idx, 1, -1 do
      local entry = jl[i]
      if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
        local name = vim.api.nvim_buf_get_name(entry.bufnr)
        if name ~= "" then
          local abs = vim.fn.fnamemodify(name, ":p")
          if abs:sub(1, #abs_wiki) == abs_wiki then
            vim.api.nvim_set_current_buf(entry.bufnr)
            if entry.lnum and entry.lnum > 0 then
              pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, entry.col or 0 })
            end
            return
          end
        end
      end
    end

    require("wiki-notes.util").notify("No hay notas previas en el historial",
      vim.log.levels.INFO)
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      local opts = { buffer = true, silent = true, noremap = true }

      vim.keymap.set("n", maps.back, wiki_back,
        vim.tbl_extend("force", opts, { desc = "Wiki: nota anterior (solo wiki)" }))

      vim.keymap.set("v", maps.insert_link, function()
        local _, s_line, s_col = unpack(vim.fn.getpos("v"))
        local _, e_line, e_col = unpack(vim.fn.getpos("."))
        if s_line > e_line or (s_line == e_line and s_col > e_col) then
          s_line, e_line = e_line, s_line
          s_col,  e_col  = e_col,  s_col
        end
        local lines = vim.api.nvim_buf_get_text(
          0, s_line - 1, s_col - 1, e_line - 1, e_col, {})
        local text = table.concat(lines, "\n")
        if text ~= "" then
          vim.api.nvim_buf_set_text(
            0, s_line - 1, s_col - 1, e_line - 1, e_col,
            { "[" .. text .. "]" })
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
            "x", false)
          vim.api.nvim_win_set_cursor(0, { s_line, s_col })
        end
      end, vim.tbl_extend("force", opts, { desc = "Wiki: seleccion -> [enlace]" }))

      vim.keymap.set("n", maps.follow_link, links.follow_or_create,
        vim.tbl_extend("force", opts, { desc = "Wiki: seguir/crear enlace" }))

      vim.keymap.set("n", maps.backlinks, links.backlinks,
        vim.tbl_extend("force", opts, { desc = "Wiki: backlinks" }))

      vim.keymap.set("n", maps.toggle_heading, function()
        local line = vim.api.nvim_get_current_line()
        local new
        if     line:match("^#%s") then new = line:gsub("^#%s", "", 1)
        elseif line:match("^#")   then new = line:gsub("^#",   "", 1)
        else new = "# " .. line end
        vim.api.nvim_set_current_line(new)
      end, vim.tbl_extend("force", opts, { desc = "Wiki: toggle #" }))

      vim.keymap.set("n", maps.toggle_checkbox, function()
        local line = vim.api.nvim_get_current_line()
        local new
        if     line:match("^%- %[% %]%s") then new = line:gsub("^%- %[% %]%s", "- [x] ", 1)
        elseif line:match("^%- %[% %]")   then new = line:gsub("^%- %[% %]",   "- [x]",  1)
        elseif line:match("^%- %[x%]%s") then new = line:gsub("^%- %[x%]%s",  "",      1)
        elseif line:match("^%- %[x%]")   then new = line:gsub("^%- %[x%]",    "",      1)
        else new = "- [ ] " .. line end
        vim.api.nvim_set_current_line(new)
      end, vim.tbl_extend("force", opts, { desc = "Wiki: toggle checkbox" }))

      vim.keymap.set("i", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        if line:match("^%- %[% %]%s*$")
          or line:match("^%- %[x%]%s*$")
          or line:match("^%- %s*$") then
          vim.api.nvim_set_current_line("")
          return "\n"
        end
        if line:match("^%- %[% %]") or line:match("^%- %[x%]") then
          return vim.api.nvim_replace_termcodes("<CR>- [ ] ", true, false, true)
        end
        if line:match("^%- %s") then
          return vim.api.nvim_replace_termcodes("<CR>- ", true, false, true)
        end
        local num = line:match("^%s*(%d+)%.")
        if num then
          return vim.api.nvim_replace_termcodes(
            "<CR>" .. (tonumber(num) + 1) .. ". ", true, false, true)
        end
        return "\n"
      end, { buffer = true, expr = true, silent = true })
    end,
  })
end

return M
