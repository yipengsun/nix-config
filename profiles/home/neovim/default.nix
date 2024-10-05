{ pkgs, lib, ... }:
let
  # this version can't be found on github anymore
  # forgot how I found it in the first place
  lastchange = pkgs.vimUtils.buildVimPlugin {
    name = "lastchange";
    src = ./lastchange;
  };

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

  enableCoc = false;
  enableNvimLsp = true;

  vistaDefaultExe =
    if enableCoc then "coc"
    else if enableNvimLsp then "nvim_lsp"
    else "ctags";
  # ^relevant options: coc, nvim_lsp, ctags
in
{
  home.sessionVariables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  home.packages = with pkgs; [
    xclip # copy-on-select for neovim
    universal-ctags # fallback for vista.vim
    nodejs # copilot plugn/coc both require this

    # language servers
    ccls
    nil
    #texlab # too damn slow
  ]
  ++ lib.optionals (enableNvimLsp) [ pyright rust-analyzer ];

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
        # misc
        vim-fugitive
        tabular
        {
          plugin = vimwiki;
          config = ''
            let g:vimwiki_global_ext = 0
            let g:vimwiki_hl_headers = 1
            let g:vimwiki_camel_case = 0
            let g:vimwiki_hl_cb_checked = 1
            let g:vimwiki_CJK_length = 1

            if isdirectory($HOME.'/data')
                let g:vimwiki_list = [{
                            \ 'path': '~/data/wiki',
                            \ 'path_html': '~/data/wiki/html',
                            \ }]
            endif
          '';
        }
        {
          plugin = vim-localvimrc;
          config = ''
            let g:localvimrc_sandbox = 0
            let g:localvimrc_persistent = 2
          '';
        }
        delimitMate
        lastchange

        # syntax
        vim-nix
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

        # telescope
        {
          plugin = telescope-nvim;
          config = ''
            lua << EOF
              require("telescope").setup {
                defaults = {
                  mappings = {
                    i = {
                      ["<C-u>"] = false,
                    },
                  },
                },
                pickers = {
                  git_files = { mappings = { i = { ["<CR>"] = "file_vsplit" } } },
                  find_files = { mappings = { i = { ["<CR>"] = "file_vsplit" } } },
                },
              }
            EOF

            nnoremap <silent><C-t> :Telescope<CR>
          '';
        }
        {
          plugin = telescope-file-browser-nvim;
          config = ''
            lua << EOF
              require("telescope").load_extension "file_browser"
            EOF
          '';
        }

        # ide
        (nvim-treesitter.withPlugins (p: pkgs.tree-sitter.allGrammars))

        vim-python-pep8-indent
        {
          plugin = nerdcommenter;
          config = ''
            let g:NERDCreateDefaultMappings = 1
            let g:NERDSpaceDelims = 1
            let g:NERDDefaultAlign = 'left'
          '';
        }
        {
          plugin = vimtex;
          config = ''
            let g:vimtex_fold_enabled = 1
            let g:tex_conceal = ""
            let g:tex_flavor = "latex"
            let g:vimtex_quickfix_ignore_filters = [
              \ "Loading 'csquotes' recommended",
              \ "Package microtype Warning",
              \ "Overfull",
              \ "Package hyperref Warning: Token not allowed",
              \ "contains only floats",
            \]
          '';
        }
        {
          plugin = vim-clang-format;
          config = "let g:clang_format#detect_style_file = 1";
        }
        {
          plugin = vista-vim;
          config = ''
            nnoremap <silent><F3> :Vista!!<CR>
            let g:vista_default_executive = '${vistaDefaultExe}'
          '';
        }

        # ui
        {
          plugin = dracula-vim;
          config = ''
            colorscheme dracula
            set termguicolors
          '';
        }
        {
          plugin = lualine-nvim;
          config = ''
            lua << EOF
              require("lualine").setup {
                options = {
                  theme = "dracula",
                  globalstatus = true,
                }
              }
            EOF
          '';
        }
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
      ] ++ lib.optionals (enableCoc) [
        {
          plugin = telescope-coc-nvim;
          config = ''
            lua << EOF
              require("telescope").setup {
                extensions = {
                  coc = {
                      theme = 'ivy',
                      prefer_locations = true,
                      push_cursor_on_edit = true,
                      timeout = 3000,
                  }
                },
              }
              require("telescope").load_extension("coc")
            EOF
          '';
        }
        coc-pyright # sadly based on JS
        coc-pairs # yet another autopairs
        coc-diagnostic # for pylint
        coc-vimtex
        coc-vimlsp
        coc-yaml
        coc-lua
        coc-rust-analyzer
      ] ++ lib.optionals (enableNvimLsp) [
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
              local capabilities = require("cmp_nvim_lsp").default_capabilities()

              local lspconfig = require("lspconfig")

              local servers = { "ccls", "rust_analyzer", "pyright", "nil_ls" }
              for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup {
                  capabilities = default_capabilities
                }
              end

              require("copilot").setup {
                suggestions = { enable = false },
                panel = { enable = false },
              }
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

    coc.enable = enableCoc;
    coc.pluginConfig = builtins.readFile ./coc-nvim.vim;
    coc.settings = {
      suggest.defaultSortMethod = "none";

      diagnostic-languageserver.filetypes.python = "pylint";
      diagnostic-languageserver.linters = {
        pylint = {
          sourceName = "pylint";
          command = "pylint";
          debounce = 100;
          args = [
            "--output-format"
            "text"
            "--score"
            "no"
            "--msg-template"
            "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'"
            "%file"
          ];
          formatPattern = [
            "^(\\d+?):(\\d+?):([a-z]+?):(.*)$"
            {
              line = 1;
              column = 2;
              endColumn = 2;
              security = 3;
              message = 4;
            }
          ];
          rootPatterns = [ "pyproject.toml" "setup.py" ".git" ];
          securities = {
            informational = "hint";
            refactor = "info";
            convention = "info";
            warning = "warning";
            error = "error";
            fatal = "error";
          };
          offsetColumn = 1;
          offsetColumnEnd = 1;
          formatLines = 1;
        };
      };

      languageserver = {
        ccls = {
          command = "ccls";
          filetypes = [ "c" "cpp" "objc" "objcpp" "cuda" ];
          rootPatterns = [ ".ccls" "compile_commands.json" ];
          initializationOptions = {
            cache = { directory = "/tmp/ccls"; };
            highlight = { lsRanges = true; };
          };
        };
        nix = {
          command = "nil";
          filetypes = [ "nix" ];
          rootPatterns = [ "flake.nix" ];
        };
      };
    };
  };
}
