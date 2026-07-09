return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        -- multilines renders single-line overlays on non-cursor lines that can't
        -- wrap and run off-screen — keep diagnostics on the cursor line only.
        multilines = { enabled = false },
        show_all_diags_on_cursorline = true,
        overflow = { mode = "wrap", padding = 4 },
        break_line = { enabled = true, after = 80 }, -- hard-break long messages so they never run off-screen
      },
    },
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "ok", package_pending = "..", package_uninstalled = "--" },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_enable = false,
      ensure_installed = {
        "eslint",
        "html",
        "cssls",
        "tailwindcss",
        "jsonls",
        "yamlls",
        "dockerls",
        "docker_compose_language_service",
        "lua_ls",
        "bashls",
        "pyright",
        "ruff",
      },
      handlers = {
        function(_) end,
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettierd",
        "prettier",
        "stylua",
        "shfmt",
        "shellcheck",
        "ruff",
        "hadolint",
        "markdownlint-cli2",
      },
      run_on_start = true,
      start_delay = 2500,
      debounce_hours = 24,
      auto_update = true, -- also update outdated tools, same 24h debounce
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local severity_names = {
        [vim.diagnostic.severity.ERROR] = "ERROR",
        [vim.diagnostic.severity.WARN] = "WARN",
        [vim.diagnostic.severity.INFO] = "INFO",
        [vim.diagnostic.severity.HINT] = "HINT",
      }

      local function format_diagnostic(diagnostic)
        local parts = { severity_names[diagnostic.severity] or "DIAGNOSTIC" }
        if diagnostic.source and diagnostic.source ~= "" then
          table.insert(parts, diagnostic.source)
        end
        if diagnostic.code and diagnostic.code ~= "" then
          table.insert(parts, "[" .. tostring(diagnostic.code) .. "]")
        end
        return table.concat(parts, " ") .. ": " .. diagnostic.message
      end

      vim.diagnostic.config({
        virtual_text = false, -- rendered by tiny-inline-diagnostic on cursor line only
        signs = {
          severity = { min = vim.diagnostic.severity.HINT },
          text = {
            [vim.diagnostic.severity.ERROR] = "E ",
            [vim.diagnostic.severity.WARN] = "W ",
            [vim.diagnostic.severity.INFO] = "I ",
            [vim.diagnostic.severity.HINT] = "H ",
          },
        },
        virtual_lines = false,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = true,
          border = "rounded",
          source = true,
          header = "",
          prefix = "",
          format = format_diagnostic,
        },
      })

      local function with_fzf(name, fallback)
        return function()
          local ok, fzf = pcall(require, "fzf-lua")
          if ok and fzf[name] then
            return fzf[name]()
          end
          return fallback()
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("macnvim_lsp_attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          if client and client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
          end

          map("gd", with_fzf("lsp_definitions", vim.lsp.buf.definition), "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", with_fzf("lsp_references", vim.lsp.buf.references), "Find references")
          map("gI", with_fzf("lsp_implementations", vim.lsp.buf.implementation), "Go to implementation")
          map("gy", with_fzf("lsp_typedefs", vim.lsp.buf.type_definition), "Go to type definition")
          map("<leader>ss", with_fzf("lsp_document_symbols", vim.lsp.buf.document_symbol), "Document symbols")
          map("<leader>sS", with_fzf("lsp_live_workspace_symbols", vim.lsp.buf.workspace_symbol), "Workspace symbols")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("K", vim.lsp.buf.hover, "Hover")
          map("gK", vim.lsp.buf.signature_help, "Signature help")

          map("<leader>ih", function()
            local filter = { bufnr = event.buf }
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
          end, "Toggle inlay hints")
        end,
      })

      -- Resolve the Python interpreter to use for a given project root so
      -- pyright/ruff see installed deps instead of reporting them missing.
      -- Order: project-local venv  ->  activated $VIRTUAL_ENV  ->  system.
      local function detect_python_path(root)
        root = root or vim.fn.getcwd()
        for _, dir in ipairs({ ".venv", "venv", "env" }) do
          local candidate = root .. "/" .. dir .. "/bin/python"
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end
        if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
          local candidate = vim.env.VIRTUAL_ENV .. "/bin/python"
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end
        local sys = vim.fn.exepath("python3")
        if sys == "" then
          sys = vim.fn.exepath("python")
        end
        return sys ~= "" and sys or "python3"
      end

      local default = { capabilities = capabilities }
      local servers = {
        pyright = {
          before_init = function(_, config)
            local py = detect_python_path(config.root_dir)
            config.settings = config.settings or {}
            config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
              pythonPath = py,
            })
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
        ruff = {
          before_init = function(_, config)
            config.init_options = config.init_options or {}
            config.init_options.settings = config.init_options.settings or {}
            config.init_options.settings.interpreter = { detect_python_path(config.root_dir) }
          end,
          init_options = {
            settings = {
              -- Editor fallback; project ruff.toml/pyproject wins in ruff server.
              lineLength = 80,
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        eslint = {
          -- Native vim.lsp.config root detection; the old util.root_pattern
          -- callback had the wrong signature for vim.lsp.config and broke
          -- eslint root resolution silently.
          root_markers = {
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts",
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            "package.json",
          },
          settings = {
            workingDirectories = { mode = "auto" },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
              },
            },
          },
        },
        jsonls = {},
        html = {},
        cssls = {},
        tailwindcss = {},
        dockerls = {},
        docker_compose_language_service = {},
        bashls = {},
      }

      -- Native LSP API (0.11+); nvim-lspconfig supplies base configs in lsp/.
      vim.lsp.config("*", { capabilities = capabilities }) -- incl. auto-installed servers
      for server_name, server_opts in pairs(servers) do
        local opts = vim.tbl_deep_extend("force", {}, default, server_opts or {})
        vim.lsp.config(server_name, opts)
        vim.lsp.enable(server_name)
      end

      -- Auto-offer LSP install for languages outside the core stack.
      -- Opening a filetype below with its server missing prompts once per
      -- session; on confirm, mason installs it and the server is enabled.
      local extra_servers = {
        go = { server = "gopls", pkg = "gopls" },
        rust = { server = "rust_analyzer", pkg = "rust-analyzer" },
        c = { server = "clangd", pkg = "clangd" },
        cpp = { server = "clangd", pkg = "clangd" },
        svelte = { server = "svelte", pkg = "svelte-language-server" },
        vue = { server = "vue_ls", pkg = "vue-language-server" },
        ruby = { server = "ruby_lsp", pkg = "ruby-lsp" },
        php = { server = "intelephense", pkg = "intelephense" },
        zig = { server = "zls", pkg = "zls" },
        terraform = { server = "terraformls", pkg = "terraform-ls" },
        prisma = { server = "prismals", pkg = "prisma-language-server" },
        graphql = { server = "graphql", pkg = "graphql-language-service-cli" },
        elixir = { server = "elixirls", pkg = "elixir-ls" },
        kotlin = { server = "kotlin_language_server", pkg = "kotlin-language-server" },
        toml = { server = "taplo", pkg = "taplo" },
      }

      local prompted = {}
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("LspAutoInstall", { clear = true }),
        callback = function(args)
          local entry = extra_servers[args.match]
          if not entry or vim.bo[args.buf].buftype ~= "" then
            return
          end

          -- mason.nvim already loaded (dependency of mason-lspconfig).
          local ok, registry = pcall(require, "mason-registry")
          if not ok then
            return
          end
          local pkg_ok, pkg = pcall(registry.get_package, entry.pkg)
          if not pkg_ok then
            return
          end

          if pkg:is_installed() then
            vim.lsp.enable(entry.server) -- idempotent
            return
          end
          if prompted[entry.server] then
            return
          end
          prompted[entry.server] = true -- ask once per session

          vim.defer_fn(function()
            vim.ui.select(
              { "Install", "Not now" },
              { prompt = ("LSP missing: install %s for %s files?"):format(entry.pkg, args.match) },
              function(choice)
                if choice ~= "Install" then
                  return
                end
                vim.notify("Mason: installing " .. entry.pkg .. "…", vim.log.levels.INFO)
                local handle_ok, handle = pcall(pkg.install, pkg)
                if not handle_ok then
                  vim.notify("Mason: failed to start install for " .. entry.pkg, vim.log.levels.ERROR)
                  return
                end
                handle:once(
                  "closed",
                  vim.schedule_wrap(function()
                    if pkg:is_installed() then
                      vim.lsp.enable(entry.server)
                      vim.notify(entry.pkg .. " installed — LSP active", vim.log.levels.INFO)
                    else
                      vim.notify(entry.pkg .. " install failed; see :Mason", vim.log.levels.ERROR)
                    end
                  end)
                )
              end
            )
          end, 150)
        end,
      })
    end,
  },
}
