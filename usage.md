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
| `<leader>ft` | Todo comments                            |
| `<leader>S`  | Search/replace project-wide (grug-far)   |
| `<leader>sw` | Replace word under cursor (grug-far)     |

## Motion & Jumping

| Key                | Action                                                |
| ------------------ | ----------------------------------------------------- |
| `s`                | **Flash jump** — 2-char label jump anywhere on screen |
| `S`                | Flash treesitter node jump                            |
| `<C-d>` / `<C-u>`  | Smooth half-page scroll (neoscroll)                   |
| `<C-f>` / `<C-b>`  | Smooth full-page scroll                               |
| `zz` / `zt` / `zb` | Smooth center / top / bottom recenter                 |
| `j` / `k`          | Down/up by visual line (wrapping-safe)                |
| `n` / `N`          | Next/prev search result, centered                     |
| `[d` / `]d`        | Prev/next diagnostic                                  |
| `[e` / `]e`        | Prev/next **error** (skips warnings)                  |
| `[h` / `]h`        | Prev/next git hunk                                    |
| `[t` / `]t`        | Prev/next TODO comment                                |
| `[a` / `]a`        | Prev/next symbol (aerial)                             |
| `[f` / `]f`        | Prev/next function (treesitter)                       |
| `[c` / `]c`        | Prev/next class (treesitter)                          |

## Windows & Buffers

| Key                                     | Action                       |
| --------------------------------------- | ---------------------------- |
| `<C-h/j/k/l>`                           | Move between splits (and tmux panes) |
| `<C-Up/Down/Left/Right>`                | Resize split                 |
| `<leader>sv` / `<leader>sh`             | Vertical / horizontal split  |
| `<S-l>` / `<S-h>`                       | Next / prev buffer           |
| `<leader>bd`                            | Close buffer                 |
| `<leader>bo`                            | Close all other buffers      |
| `<leader>w` / `<leader>q` / `<leader>Q` | Save / quit / force quit all |

## File Explorer

| Key                                   | Action                           |
| ------------------------------------- | -------------------------------- |
| `<leader>e`                           | Toggle neo-tree                  |
| `<leader>o`                           | Focus neo-tree                   |
| `-`                                   | **Oil** — edit parent dir as a buffer (rename/delete files like text, `:w` applies) |
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

## Diagnostics & Outline

Diagnostics render as a boxed message on the cursor line (tiny-inline-diagnostic); other lines show gutter signs only.

| Key          | Action                                 |
| ------------ | -------------------------------------- |
| `<leader>xd` | Line diagnostics float (focusable — press again to enter, yank from it) |
| `<leader>xy` | **Yank diagnostics on current line to clipboard** |
| `<leader>xx` | Toggle Trouble panel (all diagnostics) |
| `<leader>xX` | Buffer diagnostics (Trouble)           |
| `<leader>xs` | Trouble symbols                        |
| `<leader>xl` | Trouble LSP                            |
| `<leader>xq` | Trouble quickfix                       |
| `<leader>a`  | Toggle code outline (aerial)           |

## Format & Code

| Key          | Action                         |
| ------------ | ------------------------------ |
| `<leader>cf` | Format buffer (conform)        |
| `<leader>cF` | Force format with LSP fallback |
| `gcc` / `gc` | Comment line / selection (native) |

Format-on-save is enabled (2.5s timeout, skips huge files). Project formatter configs (`.prettierrc`, `stylua.toml`, `ruff.toml`, ...) always win over the editor defaults.

## Git

| Key                         | Action                      |
| --------------------------- | --------------------------- |
| `<leader>gg`                | **LazyGit** (full TUI)      |
| `<leader>gp`                | Preview hunk                |
| `<leader>gb` / `<leader>gB` | Blame line / toggle blame   |
| `<leader>gs` (visual)       | Stage hunk                  |
| `<leader>gr` (visual)       | Reset hunk                  |
| `<leader>gS` / `<leader>gR` | Stage / reset buffer        |
| `<leader>gu`                | Undo stage hunk             |
| `<leader>gd`                | Diffview (side-by-side)     |
| `<leader>gh` / `<leader>gH` | File history / repo history |
| `<leader>gc`                | Close diffview              |
| `<leader>gD`                | Diff this file              |

## Terminal & REPLs

| Key                                        | Action                                 |
| ------------------------------------------ | -------------------------------------- |
| `<leader>tt` / `<leader>tv` / `<leader>tf` | Terminal horizontal / vertical / float |
| `<leader>tp`                               | IPython REPL                           |
| `<leader>tn`                               | Node REPL                              |
| `<Esc>` (inside terminal)                  | Exit terminal mode                     |

## Jupyter (.ipynb via jupytext, `# %%` cells)

| Key                         | Action                    |
| --------------------------- | ------------------------- |
| `]j` / `[j`                 | Next / previous cell      |
| `<leader>jx`                | Run cell                  |
| `<leader>jj`                | Run cell and move         |
| `<leader>ja` / `<leader>jb` | Run all / cells below     |
| `<leader>jo` / `<leader>jO` | Add cell below / above    |
| `<leader>jr` / `<leader>js` | REPL open / send (iron)   |

## Harpoon (quick file switching)

| Key                         | Action                      |
| --------------------------- | --------------------------- |
| `<leader>ha`                | Add current file to harpoon |
| `<leader>hh`                | Open harpoon menu           |
| `<leader>1..4`              | Jump to harpoon slot 1–4    |
| `<leader>hp` / `<leader>hn` | Prev / next harpoon         |

## HTTP Client (kulala, `.http` files)

| Key                         | Action                        |
| --------------------------- | ----------------------------- |
| `<leader>rr`                | Run request under cursor      |
| `<leader>ra`                | Run all requests in file      |
| `<leader>rp` / `<leader>rn` | Prev / next request           |

## package.json (when editing it)

| Key                                        | Action                       |
| ------------------------------------------ | ---------------------------- |
| `<leader>ns` / `<leader>nh`                | Show / hide package versions |
| `<leader>nu` / `<leader>ni` / `<leader>nd` | Update / install / delete    |
| `<leader>nv`                               | Change package version       |

## Sessions, UI, Misc

| Key                  | Action                                    |
| -------------------- | ----------------------------------------- |
| `<leader>ps`         | Restore session for cwd                   |
| `<leader>pl`         | Restore last session                      |
| `<leader>pd`         | Stop session saving                       |
| `<leader>.`          | Scratch buffer (snacks)                   |
| `<leader>f.`         | Pick scratch buffer                       |
| `<leader>u`          | Undo tree                                 |
| `<leader>z`          | Zen mode (distraction-free)               |
| `<Esc>`              | Clear search highlight                    |
| `<A-j>` / `<A-k>`    | Move line down / up (works in visual too) |
| `<` / `>` (visual)   | Indent / outdent, stay in selection       |
| `zR` / `zM`          | Open / close all folds (ufo)              |

## Completion (insert mode, blink.cmp)

| Key             | Action                          |
| --------------- | ------------------------------- |
| `<C-Space>`     | Trigger completion menu         |
| `<C-j>` / `<C-k>` | Next / previous item          |
| `<CR>`          | Confirm                         |
| `<Tab>` / `<S-Tab>` | Select next / snippet jump  |
| `<C-e>`         | Dismiss                         |
| `<C-b>` / `<C-f>` | Scroll docs                   |

Cmdline (`:`, `/`, `?`) completes too — same keys.

## Text Objects (visual/operator, mini.ai + treesitter)

Type these after `d/c/y/v`:

| Object      | Meaning                        |
| ----------- | ------------------------------ |
| `af` / `if` | A function / inside function   |
| `ac` / `ic` | A class / inside class         |
| `aa` / `ia` | A parameter / inside parameter |
| `ao` / `io` | A block/cond/loop / inside     |
| `aq` / `iq` | Quote (any) / inside           |
| `ab` / `ib` | Bracket / inside               |

**Surround** (nvim-surround): `ys{motion}{char}` add, `ds{char}` delete, `cs{old}{new}` change. Example: `ysiw"` wrap word in quotes.

## Plugins / Health

| Command          | Action                               |
| ---------------- | ------------------------------------ |
| `:Lazy`          | Plugin manager                       |
| `:Mason`         | Install LSPs/formatters              |
| `:checkhealth`   | Full health report                   |
| `:ConformInfo`   | Formatter status for current buffer  |

---

## Top 10 to memorize

1. `<leader>ff` — find files
2. `<leader>fg` — grep project
3. `<leader>e` — explorer (`-` for oil)
4. `<leader>gg` — LazyGit
5. `<leader>cf` — format
6. `<leader>ca` — code action
7. `<leader>rn` — rename symbol
8. `gd` — go to definition
9. `K` — hover docs
10. `]e` / `[e` — jump between errors
