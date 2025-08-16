{ pkgs, lib, config, ... }:
let
  # newer vim-ledger has problems regarding auto completion
  vim-ledger-stable = pkgs.vimUtils.buildVimPlugin rec {
    pname = "vim-ledger-stable";
    version = "1.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "ledger";
      repo = "vim-ledger";
      rev = "v${version}";
      sha256 = "aWt618LWLwnWAhKN9TTCTn2mJQR7Ntt8JV3L/VDiS84=";
    };
  };
in
{
  home.sessionVariables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  home.packages = with pkgs; [
    xclip # copy-on-select for neovim
    universal-ctags # fallback for vista.vim
    nodejs # copilot/coc both require this

    # language servers
    ccls
    nil
    pyright
    rust-analyzer
    #texlab # too damn slow
  ];

  home.file.".editorconfig".text = ''
    root = true

    [*]
    end_of_line = lf
    trim_trailing_whitespace = true
    charset = utf-8
    indent_style = space

    [*.{diff,patch}]
    end_of_line = unset
    insert_final_newline = unset
    trim_trailing_whitespace = unset
    indent_size = unset

    [*.{py,yml}]
    indent_size = 4

    [*.{c,cpp,h,hpp}]
    indent_size = 2

    [*.{md,tex}]
    max_line_length = unset
  '';

  home.file.".tmp/vim/.keep".text = ""; # make sure the swp dir exists

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins;
      [
        ################
        # lazy loading #
        ################
        # misc
        {
          plugin = vim-startuptime;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "vim-startuptime",
              cmd = "StartupTime",
              before = function()
                vim.g.startuptime_tries = 10
                vim.g.startuptime_exe_path = "${config.home.homeDirectory}/.nix-profile/bin/nvim"
              end,
            }
          '';
        }
        {
          plugin = conform-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "conform.nvim",
              keys = {
                { "<LEADER>f", function() require("conform").format({ async = true }) end, },
              },
              after = function()
                require("conform").setup({
                  formatters_by_ft = {
                    python = { "black" },
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                  },
                  formatters = {
                    clang_format = {
                      prepend_args = { "--style=file", "--fallback-style=LLVM" },
                    },
                  }
                })
              end,
            }
          '';
        }
        {
          plugin = FTerm-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "FTerm.nvim",
              keys = {
                { "<F9>", function() require("FTerm").toggle() end, mode = { "n", "t" }, },
              },
              after = function()
                require("FTerm").setup({
                  border = "double",
                  dimensions = {
                    height = 0.8,
                    width = 0.9,
                  },
                })
              end,
            }
          '';
        }
        {
          plugin = goto-preview;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "goto-preview",
              keys = {
                { "<F12>", function() require("goto-preview").goto_preview_definition() end, },
              },
              after = function()
                require("goto-preview").setup({
                  width = 120,
                  height = 24,
                })
              end,
            }
          '';
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "nvim-autopairs",
              event = "InsertEnter",
              after = function()
                require("nvim-autopairs").setup()
              end,
            }
          '';
        }
        {
          plugin = trouble-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "trouble.nvim",
              keys = {
                {
                  "<LEADER>xx",
                  "<CMD>Trouble diagnostics toggle<CR>",
                  desc = "Diagnostics (Trouble)",
                },
                {
                  "<LEADER>xX",
                  "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
                  desc = "Buffer Diagnostics (Trouble)",
                },
                {
                  "<LEADER>cs",
                  "<CMD>Trouble symbols toggle focus=false<CR>",
                  desc = "Symbols (Trouble)",
                },
                {
                  "<LEADER>cl",
                  "<CMD>Trouble lsp toggle focus=false win.position=right<CR>",
                  desc = "LSP Definitions / references / ... (Trouble)",
                },
                {
                  "<LEADER>xL",
                  "<CMD>Trouble loclist toggle<CR>",
                  desc = "Location List (Trouble)",
                },
                {
                  "<LEADER>xQ",
                  "<CMD>Trouble qflist toggle<CR>",
                  desc = "Quickfix List (Trouble)",
                },
              },
              after = function()
                require("trouble").setup {
                  modes = {
                    diagnostics = { auto_open = false },
                  }
                }
              end
            }
          '';
        }

        # filetypes
        {
          plugin = csvview-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "csvview.nvim",
              cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
              after = function()
                require("csvview").setup({
                  keymaps = {
                    jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
                    jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
                    jump_next_row = { "<Enter>", mode = { "n", "v" } },
                    jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
                  },
                })
              end,
            }
          '';
        }

        # telescope
        {
          plugin = telescope-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "telescope.nvim",
              cmd = "Telescope",
              keys = {
                { "<C-p>", "<CMD>Telescope<CR>" },
                { "<C-t>", "<CMD>Telescope lsp_dynamic_workspace_symbols<CR>" },
                { "<C-f>", "<CMD>Telescope git_files<CR>" },
              },
              after = function()
                require("telescope").setup {
                  pickers = {
                    git_files = { mappings = { i = { ["<CR>"] = "file_vsplit" } } },
                    find_files = { mappings = { i = { ["<CR>"] = "file_vsplit" } } },
                    live_grep = { mappings = { i = { ["<CR>"] = "file_vsplit" } } },
                    lsp_dynamic_workspace_symbols = {
                      mappings = { i = { ["<CR>"] = "file_vsplit" } }
                    },
                  },
                }
              end,
            }
          '';
        }
        {
          plugin = telescope-file-browser-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "telescope-file-browser.nvim",
              keys = {
                { "<C-e>", "<CMD>Telescope file_browser<CR>" },
              },
              after = function()
                require("telescope").load_extension "file_browser"
              end,
            }
          '';
        }

        # debug
        {
          plugin = nvim-dap-ui;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "nvim-dap-ui",
              keys = {
                { "<C-u>", function() require('dapui').toggle() end, },
              },
              before = function()
                require("lz.n").trigger_load("nvim-dap")
              end,
              after = function()
                local dap, dapui = require("dap"), require("dapui")
                dapui.setup()

                dap.listeners.before.attach.dapui_config = function()
                  dapui.open()
                end

                dap.listeners.before.launch.dapui_config = function()
                  dapui.open()
                end

                dap.listeners.before.event_terminated.dapui_config = function()
                  dapui.close()
                end

                dap.listeners.before.event_exited.dapui_config = function()
                  dapui.close()
                end
              end,
            }
          '';
        }
        {
          plugin = nvim-dap;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "nvim-dap",
              keys = {
                { "<F5>", function() require("dap").continue() end, },
                { "<F10>", function() require("dap").step_over() end, },
                { "<F11>", function() require("dap").step_into() end, },
                { "<C-F11>", function() require("dap").step_out() end, },
                { "<LEADER>b", function() require("dap").toggle_breakpoint() end, },
              },
              after = function()
                vim.fn.sign_define("DapBreakpoint", { text="🔴" })
                vim.fn.sign_define("DapBreakpointCondition", { text="🟠" })
                vim.fn.sign_define("DapBreakpointCondition", { text="🔵" })
                vim.fn.sign_define("DapBreakpointRejected", { text="❌" })
                vim.fn.sign_define("DapStopped", { text="⟶" })

                require("dap").adapters.gdb = {
                  type = "executable",
                  command = "gdb",
                  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
                }
              end,
            }
          '';
        }

        #################
        # eager loading #
        #################
        lz-n

        # misc
        vim-fugitive
        # {
        #   plugin = direnv-vim;
        #   config = ''
        #     let g:direnv_silent_load = 1
        #   '';
        # }

        # syntax
        vim-ledger-stable
        vim-pandoc-syntax
        {
          plugin = vim-pandoc;
          config = "let g:pandoc#syntax#conceal#use = 0";
        }

        # ide
        nvim-treesitter.withAllGrammars
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
            require('Comment').setup()
          '';
        }
        {
          plugin = vimtex;
          type = "lua";
          config = ''
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_fold_enabled = true
            vim.g.tex_conceal = ""
          '';
        }


        # ui
        {
          plugin = dracula-nvim;
          type = "lua";
          config = ''
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("dracula")
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require("lualine").setup {
              options = {
                theme = "dracula",
                globalstatus = false,
                disabled_filetypes = {
                  statusline = {
                    "trouble",
                    "vista",
                  },
                },
              }
            }
          '';
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            vim.opt.list = true
            vim.opt.listchars:append("space:⋅")
            vim.opt.listchars:append("eol:↴")

            require("ibl").setup()
          '';
        }

        # auto complete
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup {
              keymap = {
                preset = "default",
              },
              completion = {
                documentation = { auto_show = true },
              },
            }
          '';
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- register language servers
            local servers = { "ccls", "rust_analyzer", "pyright", "nil_ls" }
            for _, s in ipairs(servers) do
              vim.lsp.enable(s)
            end

            -- lsp warning signs
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
            for type, icon in ipairs(signs) do
              local hl = "DiagnosticSign" .. type
              vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- rename
            local function lsp_rename()
              vim.ui.input({
                prompt = "Rename to: ",
                default = vim.fn.expand('<cword>'),
              }, function(new_name)
                -- this function is called when the user presses enter
                -- if the user cancels (e.g., with <esc>), new_name will be nil
                if not new_name or new_name == "" then
                  print("Rename cancelled.")
                  return
                end

                -- call the lsp rename function with the new name
                vim.lsp.buf.rename(new_name)
              end)
            end

            vim.keymap.set("n", "<F2>", lsp_rename, {
              noremap = true,
              silent = true,
              desc = "LSP Rename symbol under cursor",
            })
          '';
        }
      ] ++ lib.optionals (false) [
        copilot-lua
        copilot-cmp
        {
          plugin = nvim-lspconfig;
          config = ''
            lua << EOF
              -- Github Copilot
              require("copilot").setup {
                suggestions = { enable = false },
                panel = { enable = false },
              }

              -- show line diagnostics automatically in hover window
              vim.o.updatetime = 200
              vim.api.nvim_create_autocmd("CursorHold", {
                buffer = bufnr,
                callback = function()
                  local opts = {
                    focusable = false,
                    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                    border = 'rounded',
                    source = 'always',
                    prefix = ' ',
                    scope = 'cursor',
                  }
                  vim.diagnostic.open_float(nil, opts)
                end
              })

              require("copilot_cmp").setup()

              local cmp = require("cmp")

              local has_words_before = function()
                if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
              end

              cmp.setup {
                mapping = cmp.mapping.preset.insert({
                  ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
                  ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
                  -- C-b (back) C-f (forward) for snippet placeholder navigation.

                  ["<C-y>"] = cmp.mapping.complete(),
                  ["<CR>"] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                  },
                  ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and has_words_before() then
                      cmp.select_next_item()
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                  ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and has_words_before() then
                      cmp.select_prev_item()
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                }),

                sources = {
                  { name = "nvim_lsp" },
                  { name = "treesitter" },
                  { name = "copilot" },
                  { name = "buffer" },
                  { name = "omni" },
                },
              }

            EOF
          '';
        }
      ];

    extraConfig = builtins.readFile ./init.vim;

    extraPython3Packages = ps:
      with ps; [
        pynvim
        pylint
      ];
  };
}
