-- ============================================================
-- codesweep — interactive whole-codebase cleanup
--   :CodeSweep  →  pick scope + steps  →  per-file diff review
--
-- Steps (in order, all optional):
--   1. unused imports  : ruff (python), tsserver code action (ts/js)
--   2. strip comments  : treesitter nodes only — strings/docstrings
--                        never touched; directives & doc comments kept
--   3. format          : conform.nvim (existing formatter config)
--
-- Nothing is written to disk until a file is accepted in the
-- review window (a = accept, A = accept all, s = skip, <CR> = diff).
-- ============================================================
local M = {}

local config = {
  max_file_kb = 512,
  lsp_attach_timeout_ms = 8000,
  -- Comments matching any of these (lua patterns, matched lowercase) survive.
  keep_patterns = {
    "todo", "fixme", "hack:", "note:", "warn",
    "noqa", "ruff:", "type: ignore", "coding[:=]", "pragma",
    "eslint", "ts%-ignore", "ts%-expect%-error", "ts%-nocheck", "@ts%-",
    "prettier", "biome%-ignore", "stylua:", "luacheck:", "selene:",
    "fmt: ", "@preserve", "license", "copyright", "spdx",
  },
  -- Whole-comment prefixes that always survive (doc comments / annotations).
  keep_prefixes = { "#!", "/%*%*", "%-%-%-", "///" },
  comment_fts = {
    python = true, lua = true, javascript = true, typescript = true,
    javascriptreact = true, typescriptreact = true, sh = true, bash = true,
    zsh = true, css = true, scss = true, html = true, jsonc = true,
    yaml = true, toml = true, dockerfile = true,
  },
  process_fts = {
    python = true, lua = true, javascript = true, typescript = true,
    javascriptreact = true, typescriptreact = true, sh = true, bash = true,
    zsh = true, css = true, scss = true, html = true, json = true,
    jsonc = true, yaml = true, toml = true, markdown = true, dockerfile = true,
  },
  ts_fts = {
    javascript = true, typescript = true,
    javascriptreact = true, typescriptreact = true,
  },
}

-- ---------------------------------------------------------- helpers

local function file_list(scope)
  local cmd
  if vim.fn.isdirectory(".git") == 1 or vim.fn.finddir(".git", ".;") ~= "" then
    if scope == "git" then
      local changed = vim.fn.systemlist("git diff --name-only HEAD 2>/dev/null")
      local untracked = vim.fn.systemlist("git ls-files -o --exclude-standard")
      local seen, out = {}, {}
      for _, l in ipairs(vim.list_extend(changed, untracked)) do
        if l ~= "" and not seen[l] then seen[l] = true; out[#out + 1] = l end
      end
      return out
    end
    cmd = "git ls-files -c -o --exclude-standard"
  else
    cmd = "rg --files"
  end
  return vim.tbl_filter(function(l) return l ~= "" end, vim.fn.systemlist(cmd))
end

local function should_keep_comment(text, row)
  local t = vim.trim(text)
  if row == 0 and t:sub(1, 2) == "#!" then return true end
  for _, pre in ipairs(config.keep_prefixes) do
    if t:match("^" .. pre) then return true end
  end
  local lower = t:lower()
  for _, pat in ipairs(config.keep_patterns) do
    if lower:match(pat) then return true end
  end
  return false
end

-- ---------------------------------------------------------- step: imports

local function ruff_fix_imports(path, text)
  if vim.fn.executable("ruff") == 0 then return nil, "ruff not installed" end
  local res = vim.system({
    "ruff", "check", "--select", "F401", "--fix", "--exit-zero",
    "--no-cache", "--stdin-filename", path, "-",
  }, { stdin = text, text = true }):wait()
  if res.code ~= 0 or not res.stdout or res.stdout == "" then
    return nil, "ruff failed"
  end
  return res.stdout, nil
end

local function lsp_remove_unused_imports(bufnr)
  local attached = vim.wait(config.lsp_attach_timeout_ms, function()
    return #vim.lsp.get_clients({ bufnr = bufnr }) > 0
  end, 100)
  if not attached then return "no LSP attached (skipped)" end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = line_count, character = 0 },
    },
    context = {
      diagnostics = {},
      only = {
        "source.removeUnusedImports.ts",
        "source.removeUnusedImports",
        "source.removeUnused.ts",
      },
    },
  }
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    local resp = client:request_sync("textDocument/codeAction", params, 5000, bufnr)
    if resp and resp.result then
      for _, action in ipairs(resp.result) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
          return nil
        end
      end
    end
  end
  return "no removeUnusedImports action offered"
end

-- ---------------------------------------------------------- step: comments

local function collect_comment_nodes(bufnr, lang)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then return nil end
  local okp, trees = pcall(function() return parser:parse() end)
  if not okp or not trees or not trees[1] then return nil end

  local nodes, stack = {}, { trees[1]:root() }
  while #stack > 0 do
    local node = table.remove(stack)
    if node:type():find("comment") then
      nodes[#nodes + 1] = node
    else
      for child in node:iter_children() do
        if child:named() then stack[#stack + 1] = child end
      end
    end
  end
  return nodes
end

local function strip_comments(bufnr, ft)
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local nodes = collect_comment_nodes(bufnr, lang)
  if not nodes or #nodes == 0 then return 0 end

  local ranges = {}
  for _, node in ipairs(nodes) do
    local r1, c1, r2, c2 = node:range()
    local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
    if ok and text and not should_keep_comment(text, r1) then
      ranges[#ranges + 1] = { r1, c1, r2, c2 }
    end
  end
  table.sort(ranges, function(a, b)
    return a[1] > b[1] or (a[1] == b[1] and a[2] > b[2])
  end)

  local removed = 0
  for _, r in ipairs(ranges) do
    local r1, c1, r2, c2 = r[1], r[2], r[3], r[4]
    local first = vim.api.nvim_buf_get_lines(bufnr, r1, r1 + 1, false)[1] or ""
    local last = vim.api.nvim_buf_get_lines(bufnr, r2, r2 + 1, false)[1] or ""
    local prefix = first:sub(1, c1):gsub("%s+$", "")
    local suffix = last:sub(c2 + 1)
    if prefix == "" and vim.trim(suffix) == "" then
      -- Comment owned its line(s) entirely: drop them.
      vim.api.nvim_buf_set_lines(bufnr, r1, r2 + 1, false, {})
    else
      vim.api.nvim_buf_set_lines(bufnr, r1, r2 + 1, false, { prefix .. suffix })
    end
    removed = removed + 1
  end
  return removed
end

-- ---------------------------------------------------------- per-file pipeline

local function process_file(path, steps)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" or stat.size > config.max_file_kb * 1024 then
    return nil
  end
  local ft = vim.filetype.match({ filename = path })
  if not ft or not config.process_fts[ft] then return nil end

  local ok_read, orig = pcall(vim.fn.readfile, path)
  if not ok_read then return nil end
  local text = table.concat(orig, "\n") .. "\n"
  local notes = {}

  -- 1. unused imports (text-level for python, LSP for ts/js later)
  if steps.imports and ft == "python" then
    local fixed, err = ruff_fix_imports(path, text)
    if fixed then text = fixed else notes[#notes + 1] = "imports: " .. err end
  end

  -- Scratch buffer named next to the real file so formatters infer the
  -- language from the extension. Never :written — disk stays untouched.
  local name = vim.fn.fnamemodify(path, ":h") .. "/.csweep~" .. vim.fn.fnamemodify(path, ":t")
  local old = vim.fn.bufnr(name)
  if old ~= -1 then pcall(vim.api.nvim_buf_delete, old, { force = true }) end
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(text, "\n"))
  -- Trailing blank line artifact from the join above.
  local lc = vim.api.nvim_buf_line_count(bufnr)
  local last = vim.api.nvim_buf_get_lines(bufnr, lc - 1, lc, false)[1]
  if last == "" then vim.api.nvim_buf_set_lines(bufnr, lc - 1, lc, false, {}) end
  vim.bo[bufnr].filetype = ft

  if steps.imports and config.ts_fts[ft] then
    local err = lsp_remove_unused_imports(bufnr)
    if err then notes[#notes + 1] = "imports: " .. err end
  end

  local stripped = 0
  if steps.comments and config.comment_fts[ft] then
    stripped = strip_comments(bufnr, ft)
  end

  if steps.format then
    local ok_conform, conform = pcall(require, "conform")
    if ok_conform then
      pcall(conform.format, {
        bufnr = bufnr, async = false, quiet = true,
        lsp_format = "never", timeout_ms = 5000,
      })
    end
  end

  local new = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

  if table.concat(orig, "\n") == table.concat(new, "\n") then return nil end
  return { path = path, orig = orig, new = new, comments = stripped, notes = notes }
end

-- ---------------------------------------------------------- review UI

local function open_diff(entry)
  vim.cmd("tabnew")
  local lbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(lbuf, 0, -1, false, entry.orig)
  vim.api.nvim_win_set_buf(0, lbuf)
  vim.bo[lbuf].filetype = vim.filetype.match({ filename = entry.path }) or ""
  vim.cmd("diffthis | vsplit")
  local rbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(rbuf, 0, -1, false, entry.new)
  vim.api.nvim_win_set_buf(0, rbuf)
  vim.bo[rbuf].filetype = vim.bo[lbuf].filetype
  vim.cmd("diffthis")
  for _, b in ipairs({ lbuf, rbuf }) do
    vim.bo[b].modifiable = false
    vim.keymap.set("n", "q", "<cmd>tabclose<CR>", { buffer = b, silent = true })
  end
end

local function apply_entry(entry)
  vim.fn.writefile(entry.new, entry.path)
  local real = vim.fn.bufnr(vim.fn.fnamemodify(entry.path, ":p"))
  if real ~= -1 and vim.api.nvim_buf_is_loaded(real) then
    vim.api.nvim_buf_call(real, function() vim.cmd("checktime") end)
  end
end

local function open_review(entries)
  local buf = vim.api.nvim_create_buf(false, true)
  local state = {} -- row → { entry, applied }

  local function render()
    local lines = {
      "CodeSweep review — " .. #entries .. " file(s) changed",
      "<CR> diff   a accept   A accept all   s skip   q quit",
      "",
    }
    for i, e in ipairs(entries) do
      local mark = e.applied and "[x]" or (e.skipped and "[-]" or "[ ]")
      local extra = e.comments > 0 and ("  comments:-" .. e.comments) or ""
      local note = #e.notes > 0 and ("  (" .. table.concat(e.notes, "; ") .. ")") or ""
      lines[#lines + 1] = string.format("%s %s  +%d/-%d%s%s",
        mark, e.path, #e.new, #e.orig, extra, note)
      state[#lines] = e
      _ = i
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end

  local function current()
    return state[vim.api.nvim_win_get_cursor(0)[1]]
  end

  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_height(0, math.min(#entries + 4, 20))
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  render()

  local map = function(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, silent = true, desc = desc })
  end
  map("<CR>", function()
    local e = current(); if e then open_diff(e) end
  end, "Diff")
  map("a", function()
    local e = current()
    if e and not e.applied then e.applied = true; e.skipped = false; apply_entry(e); render() end
  end, "Accept file")
  map("A", function()
    for _, e in ipairs(entries) do
      if not e.applied and not e.skipped then e.applied = true; apply_entry(e) end
    end
    render()
  end, "Accept all")
  map("s", function()
    local e = current()
    if e and not e.applied then e.skipped = true; render() end
  end, "Skip file")
  map("q", "<cmd>close<CR>", "Quit review")
end

-- ---------------------------------------------------------- entry point

local function run(steps, scope)
  -- Treesitter parsers ship with the (lazy-loaded) nvim-treesitter plugin;
  -- make sure they're on the runtimepath before parsing anything.
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then pcall(lazy.load, { plugins = { "nvim-treesitter" } }) end

  local dirty = vim.fn.systemlist("git status --porcelain 2>/dev/null")
  if #dirty > 0 then
    local choice = vim.fn.confirm(
      "Working tree has uncommitted changes. Sweep anyway?\n(commit first = every sweep change is one git diff away from revert)",
      "&Proceed\n&Abort", 2)
    if choice ~= 1 then return end
  end

  local files = file_list(scope)
  local candidates = {}
  for _, f in ipairs(files) do
    local ft = vim.filetype.match({ filename = f })
    if ft and config.process_fts[ft] then candidates[#candidates + 1] = f end
  end
  if #candidates == 0 then
    vim.notify("CodeSweep: no supported files found", vim.log.levels.WARN)
    return
  end
  if #candidates > 800 then
    local choice = vim.fn.confirm(
      ("CodeSweep: %d files — this can take a while. Continue?"):format(#candidates),
      "&Yes\n&No", 2)
    if choice ~= 1 then return end
  end

  local entries = {}
  for i, path in ipairs(candidates) do
    if i % 20 == 0 then
      vim.notify(("CodeSweep: %d/%d files..."):format(i, #candidates), vim.log.levels.INFO)
      vim.cmd("redraw")
    end
    local ok, entry = pcall(process_file, path, steps)
    if ok and entry then entries[#entries + 1] = entry end
  end

  if #entries == 0 then
    vim.notify("CodeSweep: nothing to change — codebase already clean", vim.log.levels.INFO)
    return
  end
  open_review(entries)
end

function M.sweep()
  vim.ui.select(
    { "Git modified files", "Whole project" },
    { prompt = "CodeSweep scope:" },
    function(scope_choice)
      if not scope_choice then return end
      local scope = scope_choice == "Git modified files" and "git" or "all"
      local step_choice = vim.fn.confirm(
        "CodeSweep steps:",
        "&1 imports + comments + format\n&2 imports + format\n&3 comments + format\n&4 format only\n&Cancel",
        1)
      local presets = {
        [1] = { imports = true, comments = true, format = true },
        [2] = { imports = true, comments = false, format = true },
        [3] = { imports = false, comments = true, format = true },
        [4] = { imports = false, comments = false, format = true },
      }
      local steps = presets[step_choice]
      if steps then run(steps, scope) end
    end)
end

-- Exposed for testing / scripting.
M._process_file = process_file

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  vim.api.nvim_create_user_command("CodeSweep", M.sweep,
    { desc = "Interactive codebase cleanup (imports/comments/format)" })
end

return M
