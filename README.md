# Macnvim

A fast, modern Neovim configuration for full-stack development — TypeScript/JavaScript, Python, shell, Docker, Markdown, and Jupyter notebooks. Built on native Neovim APIs (0.11+ LSP, treesitter main branch) with a curated plugin set instead of a kitchen-sink distro.

![Neovim 0.11+](https://img.shields.io/badge/Neovim-0.11%2B-57A143?logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Made%20with-Lua-2C2D72?logo=lua&logoColor=white)

## Highlights

- **Native-first**: `vim.lsp.config` / `vim.lsp.enable` (no legacy lspconfig chains), nvim-treesitter main branch, native `gc` commenting
- **Fast completion**: [blink.cmp](https://github.com/saghen/blink.cmp) + LuaSnip, LSP/snippets/path/buffer sources, cmdline completion
- **Clean diagnostics**: [tiny-inline-diagnostic](https://github.com/rachartier/tiny-inline-diagnostic.nvim) — boxed message on the cursor line only, wrapped so it never runs off-screen; gutter signs elsewhere
- **Picker-centric**: [fzf-lua](https://github.com/ibhagwan/fzf-lua) for files/grep/symbols/diagnostics, [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) sidebar + [oil.nvim](https://github.com/stevearc/oil.nvim) for edit-dirs-as-buffers
- **One UI toolkit**: [snacks.nvim](https://github.com/folke/snacks.nvim) dashboard, notifier, bigfile handling, scratch buffers
- **[Kanagawa](https://github.com/rebelot/kanagawa.nvim) Dragon** theme
- **Format on save**: conform.nvim (prettier/stylua/ruff/shfmt) with project-config-wins fallbacks, nvim-lint (shellcheck/hadolint/markdownlint)
- **Git suite**: gitsigns, diffview, LazyGit, merge-conflict helpers
- **Jupyter workflow**: `.ipynb` editing via jupytext + iron.nvim REPL + cell navigation
- **Lazy-loaded**: nearly every plugin loads on demand; startup stays snappy

## Requirements

| Tool | Why |
|---|---|
| Neovim **0.11+** (0.12 recommended) | native LSP API, treesitter main branch |
| git, curl | plugin installs |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | live grep, project search |
| a [Nerd Font](https://www.nerdfonts.com/) | icons everywhere |
| Node.js + npm | TS/JS language servers |
| Python 3 + pip | pyright/ruff, Jupyter workflow |
| make, tree-sitter CLI | parser + native module builds |
| [lazygit](https://github.com/jesseduffield/lazygit) *(optional)* | `<leader>gg` git TUI |
| [fd](https://github.com/sharkdp/fd) *(optional)* | faster file finding |

macOS one-liner:

```bash
brew install neovim ripgrep fd node python tree-sitter lazygit && \
brew install --cask font-jetbrains-mono-nerd-font
```

LSP servers, formatters, and linters are installed automatically through [Mason](https://github.com/williamboman/mason.nvim) on first launch.

## Install

Back up any existing config first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

Clone and launch:

```bash
git clone https://github.com/MuhammedZohaib/Macnvim.git ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself, installs all plugins, and Mason pulls the language toolchain. Give the first launch a minute, then restart.

**Try it without touching your config** (any Neovim 0.9+):

```bash
git clone https://github.com/MuhammedZohaib/Macnvim.git ~/.config/macnvim
NVIM_APPNAME=macnvim nvim
```

## Structure

```text
~/.config/nvim/
├── init.lua                 # entry point — loads core modules, bootstraps lazy.nvim
├── lua/core/
│   ├── options.lua          # editor settings (leader = Space)
│   ├── keymaps.lua          # global keybindings
│   ├── autocmds.lua         # autocommands (yank highlight, trim whitespace, ...)
│   └── lazy.lua             # plugin manager bootstrap
└── lua/plugins/             # one file per concern, auto-imported
    ├── colorscheme.lua      # kanagawa (dragon)
    ├── lsp.lua              # servers, diagnostics, Mason, Trouble
    ├── completion.lua       # blink.cmp + LuaSnip
    ├── treesitter.lua       # parsers, textobjects, autotag
    ├── formatting.lua       # conform + nvim-lint
    ├── fzf.lua              # fzf-lua picker
    ├── neo-tree.lua         # explorer + oil.nvim
    ├── git.lua              # gitsigns, diffview, lazygit
    ├── editing.lua          # surround, flash, grug-far, which-key, folds
    ├── ui.lua               # snacks, lualine, bufferline, noice, ...
    ├── fullstack.lua        # typescript-tools, harpoon, kulala, aerial
    ├── terminal.lua         # toggleterm + REPLs
    ├── jupyter.lua          # jupytext, iron.nvim, cell navigation
    └── insights.lua         # scrollbar
```

## Languages out of the box

TypeScript/JavaScript (typescript-tools + ESLint), Python (pyright + ruff), Lua, Bash, HTML/CSS/Tailwind, JSON, YAML, Docker/Compose, Markdown. Opening a filetype that needs an uninstalled server prompts a one-key Mason install (Go, Rust, C/C++, Svelte, Vue, Ruby, PHP, Zig, Terraform, Prisma, GraphQL, Elixir, Kotlin, and more).

## Usage

Leader is **Space**. Press it and pause — which-key shows every binding. Full keymap reference: **[usage.md](./usage.md)**.

The ten to learn first:

| Key | Action |
|---|---|
| `<leader>ff` / `<leader>fg` | find files / grep project |
| `<leader>e` | file explorer |
| `-` | edit parent directory (oil) |
| `gd` / `K` | definition / hover docs |
| `<leader>ca` / `<leader>rn` | code action / rename |
| `<leader>gg` | LazyGit |
| `<leader>cf` | format buffer |
| `]d` `[d` / `]e` `[e` | next/prev diagnostic / error |
| `s` | flash jump anywhere on screen |

## Customization

- Editor behavior: `lua/core/options.lua`
- Add/remove plugins: drop a spec file in `lua/plugins/` — lazy.nvim picks it up
- Line length: `colorcolumn`/`textwidth` in `options.lua`, formatter widths in `formatting.lua` (project configs always win)
- Theme: swap the spec in `lua/plugins/colorscheme.lua`

## Troubleshooting

```vim
:checkhealth          " full health report
:Lazy                 " plugin states, sync, profile startup
:Mason                " language tool installs
:ConformInfo          " which formatter runs for this buffer
:checkhealth vim.lsp  " attached servers
```

Cold smoke test from a shell — expect empty output:

```bash
nvim --headless +qa 2>&1 | grep -iE "error|deprec|fail"
```
