-- lua/wiki-notes/util.lua
local M = {}

function M.notify(msg, level)
  vim.notify("wiki-notes: " .. msg, level or vim.log.levels.INFO)
end

function M.escape(s)       return vim.fn.fnameescape(s) end
function M.shell_escape(s) return vim.fn.shellescape(s) end

function M.current_dir()       return vim.fn.expand("%:p:h") end
function M.current_note_name() return vim.fn.expand("%:t:r") end

function M.has_ripgrep() return vim.fn.executable("rg") == 1 end

function M.grep(pattern, dir, cfg, opts)
  opts = opts or {}
  local flag = opts.fixed and "-F" or ""
  local cmd
  if cfg.use_ripgrep and M.has_ripgrep() then
    cmd = string.format(
      "rg -n --no-heading --color=never %s -g '*.md' %s %s",
      flag, M.shell_escape(pattern), M.shell_escape(dir))
  else
    cmd = string.format(
      "grep -rn --color=never %s --include='*.md' %s %s 2>/dev/null",
      flag, M.shell_escape(pattern), M.shell_escape(dir))
  end
  return vim.fn.systemlist(cmd)
end

function M.grep_fixed(pattern, dir, cfg)
  return M.grep(pattern, dir, cfg, { fixed = true })
end

function M.parse_grep_line(line)
  local file, lnum, rest = line:match("^([^:]+):(%d+):(.*)$")
  if not file then return nil end
  return { file = file, lnum = tonumber(lnum), text = rest }
end

function M.find_buf(path)
  local abs = vim.fn.fnamemodify(path, ":p")
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" and vim.fn.fnamemodify(name, ":p") == abs then
        return b
      end
    end
  end
  return nil
end

function M.open_at(file, lnum)
  local buf = M.find_buf(file)
  if buf then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd("edit! " .. M.escape(file))
  end
  if lnum then
    pcall(vim.api.nvim_win_set_cursor, 0, { lnum, 0 })
    vim.cmd("normal! zz")
  end
end

function M.pick(items, prompt, on_choice, format_item)
  if not items or #items == 0 then
    M.notify("Sin resultados"); return
  end
  if #items == 1 then on_choice(items[1]); return end
  vim.ui.select(items, {
    prompt = prompt,
    format_item = format_item,
  }, function(choice)
    if choice then on_choice(choice) end
  end)
end

function M.create_location(cfg)
  local cur  = vim.fn.fnamemodify(M.current_dir(), ":p")
  local root = vim.fn.fnamemodify(cfg.dir, ":p")
  if cur == root then return cfg.dir end
  return cfg.notes_dir
end

function M.resolve_note(cfg, name)
  local candidates = { name }
  local sl = M.slug(name)
  if sl ~= "" and sl ~= name then table.insert(candidates, sl) end

  local cur = M.current_dir()
  for _, cand in ipairs(candidates) do
    local p = cur .. "/" .. cand .. cfg.ext
    if vim.fn.filereadable(p) == 1 then return p end
  end

  for _, cand in ipairs(candidates) do
    local p = cfg.notes_dir .. "/" .. cand .. cfg.ext
    if vim.fn.filereadable(p) == 1 then return p end
  end

  for _, cand in ipairs(candidates) do
    local cmd = string.format(
      "find %s -type f -name %s 2>/dev/null",
      M.shell_escape(cfg.dir), M.shell_escape(cand .. cfg.ext))
    local matches = vim.fn.systemlist(cmd)
    if #matches > 0 then return matches[1] end
  end

  return nil
end

function M.slug(s)
  if not s or s == "" then return "" end
  s = s:lower()
  local subs = {
    ["á"]="a", ["à"]="a", ["ä"]="a", ["â"]="a", ["ã"]="a",
    ["é"]="e", ["è"]="e", ["ë"]="e", ["ê"]="e",
    ["í"]="i", ["ì"]="i", ["ï"]="i", ["î"]="i",
    ["ó"]="o", ["ò"]="o", ["ö"]="o", ["ô"]="o", ["õ"]="o",
    ["ú"]="u", ["ù"]="u", ["ü"]="u", ["û"]="u",
    ["ñ"]="n", ["ç"]="c",
  }
  for k, v in pairs(subs) do s = s:gsub(k, v) end
  s = s:gsub("[^%w]+", "-")
  s = s:gsub("%-+", "-")
  s = s:gsub("^%-", ""):gsub("%-$", "")
  return s
end

return M
