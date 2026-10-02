-- lua/wiki-notes/refs.lua
local util = require("wiki-notes.util")
local M = {}

local function wiki_files(cfg)
  local seen, out = {}, {}
  local function add(files)
    for _, f in ipairs(files) do
      local abs = vim.fn.fnamemodify(f, ":p")
      if not seen[abs] then
        seen[abs] = true
        out[#out + 1] = f
      end
    end
  end
  add(vim.fn.globpath(cfg.dir, "*.md",    false, true))
  add(vim.fn.globpath(cfg.dir, "**/*.md", false, true))
  return out
end

local function replace_match(inner, old_slug, replacement, mode)
  if util.slug(inner) ~= old_slug then return nil end
  if mode == "rename" then
    return "[" .. replacement .. "]"
  else
    return replacement  -- soft / strong delete: sin corchetes
  end
end

function M.update(cfg, old_slug, replacement, skip_path, mode)
  local files = wiki_files(cfg)
  local skip_abs = vim.fn.fnamemodify(skip_path, ":p")
  local count = 0

  for _, f in ipairs(files) do
    local f_abs = vim.fn.fnamemodify(f, ":p")
    if f_abs ~= skip_abs then
      local b = util.find_buf(f)
      local loaded = b and vim.api.nvim_buf_is_loaded(b)

      local content
      if loaded then
        content = vim.api.nvim_buf_get_lines(b, 0, -1, false)
      else
        content = vim.fn.readfile(f)
      end

      local out, changed = {}, false
      for _, l in ipairs(content) do
        local keep = true

        if mode == "strong-delete" then
          local m = l:match("^%s*[%-%*%+] %[(.-)%]%s*$")
          if m and util.slug(m) == old_slug then
            keep = false
            changed = true
          end
        end

        if keep then
          if not l:find("[", 1, true) then
            out[#out + 1] = l
          else
            local new_l = l:gsub("%[(.-)%]", function(inner)
              return replace_match(inner, old_slug, replacement, mode)
            end)
            if new_l ~= l then changed = true end
            out[#out + 1] = new_l
          end
        end
      end

      if changed then
        if loaded then
          local was_dirty = vim.bo[b].modified
          vim.api.nvim_buf_set_lines(b, 0, -1, false, out)
          if not was_dirty then
            vim.api.nvim_buf_call(b, function()
              vim.cmd("silent! write")
            end)
          end
        else
          vim.fn.writefile(out, f)
        end
        count = count + 1
      end
    end
  end

  return count
end

return M
