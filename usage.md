# Macnvim — Keymap Reference

Leader = **Space**. Localleader = **\\**. Press `<Space>` and pause — which-key shows everything. Searchable list: `<leader>fk`.

## Files & Search (fzf-lua)

| Key          | Action                                   |
| ------------ | ---------------------------------------- |
| `<leader>ff` | Find files                               |
| `<leader>fg` | Live grep (search text in project)       |
| `<leader>fb` | Switch buffer                            |
| `<leader>fh` | Help tags                                |
| `<leader>fr` | Recent files                             |
| `<leader>fw` | Grep word under cursor                   |
| `<leader>fc` | All commands                             |
| `<leader>fk` | All keymaps (forgot a binding? hit this) |
| `<leader>fd` | Workspace diagnostics                    |
| `<leader>fs` | Document symbols                         |
| `<leader>fS` | Workspace symbols                        |

Project-wide replace: `<leader>fg` the term, send to quickfix (`ctrl-q` in the picker), then `:cdo s/old/new/g | update`.

## Motion & Jumping

| Key         | Action                                 |
| ----------- | -------------------------------------- |
| `j` / `k`   | Down/up by visual line (wrapping-safe) |
| `n` / `N`   | Next/prev search result, centered      |
| `[d` / `]d` | Prev/next diagnostic                   |
| `[e` / `]e` | Prev/next **error** (skips warnings)   |
| `[h` / `]h` | Prev/next git hunk                     |
| `[f` / `]f` | Prev/next function (treesitter)        |
| `[c` / `]c` | Prev/next class (treesitter)           |

## Windows & Buffers

| Key                                     | Action                               |
| --------------------------------------- | ------------------------------------ |
| `<C-h/j/k/l>`                           | Move between splits (and tmux panes) |
| `<C-Up/Down/Left/Right>`                | Resize split                         |
| `<leader>sv` / `<leader>sh`             | Vertical / horizontal split          |
| `<S-l>` / `<S-h>`                       | Next / prev buffer                   |
| `<leader>bd`                            | Close buffer                         |
| `<leader>bo`                            | Close all other buffers              |
| `<leader>w` / `<leader>q` / `<leader>Q` | Save / quit / force quit all         |

## File Explorer (neo-tree)

| Key                                   | Action                           |
| ------------------------------------- | -------------------------------- |
| `<leader>e`                           | Toggle explorer                  |
| `<leader>o`                           | Focus explorer                   |
| Inside tree: `l` / `h` / `<CR>` / `/` | Open / close / open / fuzzy find |

## LSP (active when a language server attaches)

| Key                         | Action                               |
| --------------------------- | ------------------------------------ |
| `gd`                        | Go to definition                     |
| `gD`                        | Go to declaration                    |
| `gr`                        | Find references                      |
| `gI`                        | Go to implementation                 |
| `gy`                        | Go to type definition                |
| `K`                         | Hover docs                           |
| `gK`                        | Signature help                       |
| `<leader>rn`                | Rename symbol                        |
| `<leader>ca`                | Code action (quick fixes, refactors) |
| `<leader>ih`                | Toggle inlay hints                   |
| `<leader>ss` / `<leader>sS` | Doc / workspace symbols              |

## TypeScript (when editing .ts/.tsx)

| Key           | Action                  |
| ------------- | ----------------------- |
| `<leader>tsi` | Add missing imports     |
| `<leader>tso` | Organize imports        |
| `<leader>tsu` | Remove unused imports   |
| `<leader>tsf` | Fix all auto-fixes      |
| `<leader>tsd` | Go to source definition |

## Diagnostics

Diagnostics render as a boxed message on the cursor line (tiny-inline-diagnostic); other lines show gutter signs only.

| Key          | Action                                                                   |
| ------------ | ------------------------------------------------------------------------ |
| `<leader>xd` | Line diagnostics float (focusable — press again to enter, yank from it) |
| `<leader>xy` | **Yank diagnostics on current line to clipboard**                        |
| `<leader>fd` | Workspace diagnostics picker (fzf)                                       |

## Format & Code

| Key          | Action                                           |
| ------------ | ------------------------------------------------ |
| `<leader>cf` | Format buffer (conform)                          |
| `<leader>cF` | Force format with LSP fallback                   |
| `gcc` / `gc` | Comment line / selection (native)                |
| `zR` / `zM`  | Open / close all folds (native treesitter folds) |

Format-on-save is enabled (2.5s timeout, skips huge files). Project formatter configs (`.prettierrc`, `stylua.toml`, `ruff.toml`, ...) always win over the editor defaults (120 columns, markdown prose hard-wrapped).

## Git

| Key                         | Action                              |
| --------------------------- | ----------------------------------- |
| `<leader>gg`                | **LazyGit** (full TUI, snacks float) |
| `<leader>gp`                | Preview hunk                        |
| `<leader>gb` / `<leader>gB` | Blame line / toggle blame           |
| `<leader>gs` (visual)       | Stage hunk                          |
| `<leader>gr` (visual)       | Reset hunk                          |
| `<leader>gS` / `<leader>gR` | Stage / reset buffer                |
| `<leader>gu`                | Undo stage hunk                     |
| `<leader>gD`                | Diff this file (gitsigns)           |

Diffs, history, and merge conflicts: use LazyGit (`<leader>gg`) — it covers side-by-side diffs, file history, and conflict resolution.

## Terminal & REPLs (snacks.terminal)

| Key                                        | Action                                 |
| ------------------------------------------ | -------------------------------------- |
| `<leader>tt` / `<leader>tv` / `<leader>tf` | Terminal bottom / right / float        |
| `<leader>tp`                               | IPython REPL                           |
| `<leader>tn`                               | Node REPL                              |
| `<Esc>` (inside terminal)                  | Exit terminal mode                     |

## UI, Misc

| Key                | Action                                    |
| ------------------ | ----------------------------------------- |
| `<leader>.`        | Scratch buffer (snacks)                   |
| `<leader>f.`       | Pick scratch buffer                       |
| `<Esc>`            | Clear search highlight                    |
| `<A-j>` / `<A-k>`  | Move line down / up (works in visual too) |
| `<` / `>` (visual) | Indent / outdent, stay in selection       |

## Completion (insert mode, blink.cmp)

| Key                 | Action                     |
| ------------------- | -------------------------- |
| `<C-Space>`         | Trigger completion menu    |
| `<C-j>` / `<C-k>`   | Next / previous item       |
| `<CR>`              | Confirm                    |
| `<Tab>` / `<S-Tab>` | Select next / snippet jump |
| `<C-e>`             | Dismiss                    |
| `<C-b>` / `<C-f>`   | Scroll docs                |

Cmdline (`:`, `/`, `?`) completes too — same keys.

## Surround (nvim-surround)

`ys{motion}{char}` add, `ds{char}` delete, `cs{old}{new}` change. Example: `ysiw"` wraps the word in quotes.

## Plugins / Health

| Command        | Action                              |
| -------------- | ----------------------------------- |
| `:Lazy`        | Plugin manager                      |
| `:Mason`       | Install LSPs/formatters             |
| `:checkhealth` | Full health report                  |
| `:ConformInfo` | Formatter status for current buffer |

---

## Top 10 to memorize

1. `<leader>ff` — find files
2. `<leader>fg` — grep project
3. `<leader>e` — explorer
4. `<leader>gg` — LazyGit
5. `<leader>cf` — format
6. `<leader>ca` — code action
7. `<leader>rn` — rename symbol
8. `gd` — go to definition
9. `K` — hover docs
10. `]e` / `[e` — jump between errors
