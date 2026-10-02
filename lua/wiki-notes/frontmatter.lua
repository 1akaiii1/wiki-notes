-- lua/wiki-notes/frontmatter.lua
local util = require("wiki-notes.util")
local M = {}

local function parse_inline(inner)
  local tags = {}
  for t in inner:gmatch("[^,]+") do
    t = t:match("^%s*(.-)%s*$")
    if t ~= "" then table.insert(tags, t) end
  end
  return tags
end

local function render(tags)
  if #tags == 0 then return "tags: []" end
  return "tags: [" .. table.concat(tags, ", ") .. "]"
end

local function locate(lines)
  if lines[1] ~= "---" then return nil end
  local fm_end
  for i = 2, #lines do
    if lines[i] == "---" then fm_end = i; break end
  end
  if not fm_end then return nil end

  for i = 2, fm_end - 1 do
    local rest = lines[i]:match("^tags:%s*(.*)$")
    if rest then
      if rest:match("^%[") then
        local inner = rest:match("^%[(.*)%]%s*$") or ""
        return {
          fm_end = fm_end,
          tags_start = i, tags_end = i,
          tags = parse_inline(inner),
        }
      end
      local tags, j = {}, i
      while j + 1 < fm_end do
        local item = lines[j + 1]:match("^%s*%-%s*(.-)%s*$")
        if not item then break end
        if item ~= "" then table.insert(tags, item) end
        j = j + 1
      end
      return {
        fm_end = fm_end,
        tags_start = i, tags_end = j,
        tags = tags,
      }
    end
  end

  return { fm_end = fm_end, tags_start = nil, tags_end = nil, tags = {} }
end

local function ensure()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local info = locate(lines)
  if info then return info end
  local fm = {
    "---",
    "title: " .. vim.fn.expand("%:t:r"),
    "created: " .. os.date("%Y-%m-%d"),
    "tags: []",
    "---",
    "",
  }
  vim.api.nvim_buf_set_lines(0, 0, 0, false, fm)
  return locate(vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local function write(info, tags)
  if info.tags_start then
    vim.api.nvim_buf_set_lines(0, info.tags_start - 1, info.tags_end,
      false, { render(tags) })
  else
    vim.api.nvim_buf_set_lines(0, info.fm_end - 1, info.fm_end - 1,
      false, { render(tags) })
  end
end

function M.add(tag)
  if not tag or tag == "" then
    util.notify("Uso: :WNtag add <tag>", vim.log.levels.ERROR); return
  end
  local info = ensure()
  for _, t in ipairs(info.tags) do
    if t == tag then
      util.notify("Ya existe: " .. tag); return
    end
  end
  table.insert(info.tags, tag)
  write(info, info.tags)
  util.notify("Tag anadido: " .. tag)
end

function M.remove(tag)
  if not tag or tag == "" then
    util.notify("Uso: :WNtag remove <tag>", vim.log.levels.ERROR); return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local info = locate(lines)
  if not info then util.notify("Sin frontmatter"); return end

  local out, found = {}, false
  for _, t in ipairs(info.tags) do
    if t == tag then found = true else table.insert(out, t) end
  end
  if not found then util.notify("No esta: " .. tag); return end
  write(info, out)
  util.notify("Tag eliminado: " .. tag)
end

function M.setup(_cfg)
  vim.api.nvim_create_user_command("WNtag", function(args)
    local sub = args.fargs[1]
    local tag = args.fargs[2]
    if sub == "add" then
      M.add(tag)
    elseif sub == "remove" then
      M.remove(tag)
    else
      util.notify("Uso: :WNtag {add|remove} <tag>", vim.log.levels.ERROR)
    end
  end, {
    nargs = "+",
    desc = "Editar tags del frontmatter",
    complete = function(arglead)
      return vim.tbl_filter(function(s)
        return s:sub(1, #arglead) == arglead
      end, { "add", "remove" })
    end,
  })
end

return M
