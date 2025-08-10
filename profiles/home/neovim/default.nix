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

  enableNvimLsp = true;
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
    #texlab # too damn slow
    pyright
    rust-analyzer
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

        # telescope
        {
          plugin = telescope-nvim;
          type = "lua";
          optional = true;
          config = ''
            require("lz.n").load {
              "telescope.nvim",
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

        #################
        # eager loading #
        #################
        lz-n

        # misc
        vim-fugitive
        {
          plugin = direnv-vim;
          config = ''
            let g:direnv_silent_load = 1
          '';
        }
        #delimitMate

        # syntax
        vim-ledger-stable
        vim-pandoc-syntax
        {
          plugin = vim-pandoc;
          config = "let g:pandoc#syntax#conceal#use = 0";
        }
        {
          plugin = csv-vim;
          config = ''
            au BufRead,BufNewFile *.csv set ft=csv
            au BufRead,BufNewFile *.csv nnoremap \e :WhatColumn<CR>
            au BufRead,BufNewFile *.csv nnoremap \q :HiColumn<CR>
            au BufRead,BufNewFile *.csv nnoremap \Q :HiColumn!<CR>
          '';
        }
        wgsl-vim

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

        # debug
        /*
        nvim-dap-ui
        {
          plugin = nvim-dap;
          config = ''
            lua << EOF
              local dap, dapui = require("dap"), require("dapui")

              vim.fn.sign_define("DapBreakpoint", { text="🔴" })
              vim.fn.sign_define("DapBreakpointCondition", { text="🟠" })
              vim.fn.sign_define("DapBreakpointCondition", { text="🔵" })
              vim.fn.sign_define("DapBreakpointRejected", { text="❌" })
              vim.fn.sign_define("DapStopped", { text="⟶" })

              dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
              }

              dapui.setup();

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

              vim.keymap.set("n", "<F5>",
                            "<cmd>lua require('dap').continue()<CR>",
                            { noremap = true, silent = true })
              vim.keymap.set("n", "<F10>",
                            "<cmd>lua require('dap').step_over()<CR>",
                            { noremap = true, silent = true })
              vim.keymap.set("n", "<F11>",
                            "<cmd>lua require('dap').step_into()<CR>",
                            { noremap = true, silent = true })
              vim.keymap.set("n", "<C-F11>",
                            "<cmd>lua require('dap').step_out()<CR>",
                            { noremap = true, silent = true })

              vim.keymap.set("n", "<C-u>",
                            "<cmd>lua require('dapui').toggle()<CR>",
                            { noremap = true, silent = true })

              vim.keymap.set("n", "<leader>b",
                            "<cmd>lua require('dap').toggle_breakpoint()<CR>",
                            { noremap = true, silent = true })
            EOF
          '';
        }
        */

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
        /*
        {
          plugin = vim-floaterm;
          config = ''
            nnoremap <silent> <F9> :FloatermToggle<CR>
            tnoremap <silent> <F9> <C-\><C-n>:FloatermToggle<CR>
          '';
        }
        {
          plugin = indent-blankline-nvim;
          config = ''
            lua << EOF
              vim.opt.list = true
              vim.opt.listchars:append("space:⋅")
              vim.opt.listchars:append("eol:↴")

              require("ibl").setup()
            EOF
          '';
        }
        {
          plugin = goto-preview;
          config = ''
            lua << EOF
              require("goto-preview").setup {
                width = 120,
                height = 24,
              }

              vim.keymap.set("n", "<F12>",
                            "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
                            { noremap = true, silent = true })
            EOF
          '';
        }
        */
      ] ++ lib.optionals (false) [
        nvim-cmp
        cmp-nvim-lsp
        cmp-treesitter
        cmp-buffer
        cmp-omni
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

              -- lsp warning signs
              local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
              for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
              end

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

              -- auto completion
              local capabilities = require("cmp_nvim_lsp").default_capabilities()

              local lspconfig = require("lspconfig")

              local servers = { "ccls", "rust_analyzer", "pyright", "nil_ls" }
              for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup {
                  capabilities = default_capabilities
                }
              end

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

              -- rename
              local function dorename(win)
                local new_name = vim.trim(vim.fn.getline('.'))
                vim.api.nvim_win_close(win, true)
                vim.lsp.buf.rename(new_name)
              end

              local function rename()
                local opts = {
                  relative = 'cursor',
                  row = 0,
                  col = 0,
                  width = 30,
                  height = 1,
                  style = 'minimal',
                  border = 'single'
                }
                local cword = vim.fn.expand('<cword>')
                local buf = vim.api.nvim_create_buf(false, true)
                local win = vim.api.nvim_open_win(buf, true, opts)
                local fmt =  '<cmd>lua Rename.dorename(%d)<CR>'

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, {cword})
                vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', string.format(fmt, win), {silent=true})
              end

              _G.Rename = {
                rename = rename,
                dorename = dorename
              }

              vim.api.nvim_set_keymap("n", "<F2>", "<cmd>lua Rename.rename()<CR>",
                { noremap = true, silent = true })
            EOF
          '';
        }
        {
          plugin = trouble-nvim;
          config = ''
            lua << EOF
              require("trouble").setup {
                modes = {
                  diagnostics = { auto_open = false },
                }
              }

              vim.keymap.set("n", "<F3>",
                            "<cmd>Trouble symbols toggle focus=false<CR>",
                            { noremap = true, silent = true })
              vim.keymap.set("n", "<C-m>",
                            "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
                            { noremap = true, silent = true })
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
