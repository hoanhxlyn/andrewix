-- Thin layer over lz.n (plugins are installed by Nix/mnw, so no vim.pack here).
--   setup(specs)  specs = spec | { import = "lazy" } | nested list of them
--
-- Spec = lz.n spec fields plus:
--   dependencies   string[]: mnw `opt` plugin names, :packadd-ed before the plugin loads
--   virtual        no package of its own (load is a no-op), only hooks/triggers
-- `{ import = "lazy" }` requires every module directly under lua/lazy, each returning a spec or a list of specs.
local M = {}

local function noop() end

---A single spec has a name at [1] and no nested spec after it; anything else is a list of specs.
local function is_single(spec)
  return type(spec) == "string" or (type(spec[1]) == "string" and spec[2] == nil)
end

local function as_table(spec)
  return type(spec) == "string" and { spec } or spec
end

---Modules directly under lua/<import>: files and directories with an init.lua, sorted.
---@param import string module name, e.g. "lazy"
---@return string[]
local function import_modules(import)
  local root = vim.fs.joinpath("lua", (import:gsub("%.", "/")))
  local found = {}
  for _, dir in ipairs(vim.api.nvim_get_runtime_file(root, true)) do
    for name, entry_kind in vim.fs.dir(dir) do
      local path = vim.fs.joinpath(dir, name)
      ---@type string?
      local kind = entry_kind
      if kind == "link" then
        local stat = vim.uv.fs_stat(path)
        kind = stat and stat.type
      end
      local mod
      if kind == "file" and name:sub(-4) == ".lua" then
        mod = name:sub(1, -5)
      elseif kind == "directory" and vim.uv.fs_stat(vim.fs.joinpath(path, "init.lua")) then
        mod = name
      end
      if mod and mod ~= "init" then
        found[import .. "." .. mod] = true
      end
    end
  end
  local mods = vim.tbl_keys(found)
  table.sort(mods)
  return mods
end

-- Spec fields consumed here; everything else goes to lz.n untouched.
local own_fields = { "dependencies", "virtual" }

local function process(spec, lz_specs)
  local lz = {}
  for k, v in pairs(spec) do
    if not vim.list_contains(own_fields, k) then
      lz[k] = v
    end
  end
  if spec.virtual then
    lz.load = lz.load or noop
  end
  local deps = spec.dependencies
  if deps and #deps > 0 then
    local before = spec.before
    lz.before = function(plugin)
      for _, name in ipairs(deps) do
        vim.cmd.packadd(name)
      end
      if before then
        before(plugin)
      end
    end
  end
  lz_specs[#lz_specs + 1] = lz
end

---@param specs table a spec, `{ import = "module" }`, or a (nested) list of them
function M.setup(specs)
  local lz_specs = {}

  local function walk(list)
    if list.import then
      for _, mod in ipairs(import_modules(list.import)) do
        local ok, result = pcall(require, mod)
        if ok and type(result) == "table" then
          walk(result)
        elseif not ok then
          vim.notify(("(deps) Failed to import %s: %s"):format(mod, result), vim.log.levels.ERROR)
        end
      end
    elseif is_single(list) then
      process(as_table(list), lz_specs)
    else
      for _, item in ipairs(list) do
        walk(item)
      end
    end
  end
  walk(specs)

  require("lz.n").load(lz_specs)
end

return M
