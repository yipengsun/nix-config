{ pkgs, lib, config, ... }:
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

  # feels laggy
  im-select-nvim = pkgs.vimUtils.buildVimPlugin rec {
    pname = "im-select-nvim";
    version = "20230830";
    src = pkgs.fetchFromGitHub {
      owner = "keaising";
      repo = "im-select.nvim";
      rev = "13627c8";
      sha256 = "sha256-FbDRm7/KqGax2n8L9WWPz49vHMKhrHF+DrNhyzhibHc=";
    };
  };

  vim-im-select = pkgs.vimUtils.buildVimPlugin rec {
    pname = "vim-im-select";
    version = "20230830";
    src = pkgs.fetchFromGitHub {
      owner = "brglng";
      repo = "vim-im-select";
      rev = "3ddf36a";
      sha256 = "sha256-UxxnGX5FoQhhXKZFRZUBqcFelYa+s7KFqvM0eSg1Reg=";
    };
  };

  isRoot = config.home.username == "root";
in
{

  home.sessionVariables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  home.packages = with pkgs; [
    xclip # copy-on-select for neovim
    nodejs # required by coc-nvim

    # language servers
    ccls
    #texlab # too damn slow
    rnix-lsp
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

    plugins = with pkgs.vimPlugins; [
      # misc
      vim-fugitive
      tabular

      # float terminal
      {
        plugin = vim-floaterm;
        config = ''
          nnoremap <silent> <F9> :FloatermToggle<CR>
          tnoremap <silent> <F9> <C-\><C-n>:FloatermToggle<CR>
        '';
      }

      {
        plugin = editorconfig-nvim;
        config = ''
          let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
          au FileType gitcommit let b:EditorConfig_disable = 1
        '';
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
      {
        plugin = vim-localvimrc;
        config = ''
          let g:localvimrc_sandbox = 0
          let g:localvimrc_persistent = 2
        '';
      }
      delimitMate
      { plugin = vim-pandoc; config = "let g:pandoc#syntax#conceal#use = 0"; }
      lastchange

      # syntax
      vim-nix
      vim-ledger-stable
      vim-pandoc-syntax

      # file manager
      telescope-nvim
      {
        plugin = telescope-file-browser-nvim;
        config = ''
          lua << EOF
            require("telescope").load_extension "file_browser"
          EOF
        '';
      }

      # ide
      { plugin = coc-nvim; config = builtins.readFile ./coc-nvim.vim; }
      #vim-lsp-cxx-highlight
      coc-pyright # sadly based on JS
      coc-pairs # yet another autopairs
      coc-diagnostic # for pylint
      coc-vimtex
      coc-vimlsp
      coc-yaml
      coc-lua
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
      vim-python-pep8-indent
      {
        plugin = nerdcommenter;
        config = ''
          let g:NERDCreateDefaultMappings = 1
          let g:NERDSpaceDelims = 1
          let g:NERDDefaultAlign = 'left'

          func! AutoHead()
              let fl = line(".")
              if getline(fl) !~ "^$"
                  let fl += 1
              endif
              let ll = fl+2
              call setline(fl, "Author: Yipeng Sun")
              call append(fl, "Last Change: " . strftime("%a %b %d, %Y at %I:%M %p %z"))
              call append(fl, "License: GPLv3")
              call append(fl+2, "")
              execute fl . ','. ll .'call nerdcommenter#Comment("n", "Toggle")'
          endfunc
          nnoremap ,h :call AutoHead()<CR>
        '';
      }
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
          nnoremap \ty :VimwikiToggleListItem<CR>
        '';
      }
      { plugin = vim-clang-format; config = "let g:clang_format#detect_style_file = 1"; }

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
      { plugin = tagbar; config = "nnoremap <silent><F2> :TagbarToggle<CR>"; }
      (nvim-treesitter.withPlugins (p: pkgs.tree-sitter.allGrammars))
      {
        plugin = indent-blankline-nvim;
        config = ''
          lua << EOF
            vim.opt.list = true
            vim.opt.listchars:append("space:⋅")
            vim.opt.listchars:append("eol:↴")

            require("indent_blankline").setup {
                space_char_blankline = " ",
                show_current_context = true,
                show_current_context_start = true,
            }
          EOF
        '';
      }
    ] ++ lib.optionals (!isRoot) [
      {
        plugin = vim-im-select;
        config = ''
          if has('wsl')
            let g:im_select_command = "im-select.exe"
          endif
        '';
      }
      # {
      #   plugin = im-select-nvim;
      #   config = ''
      #     lua << EOF
      #       require('im_select').setup()
      #     EOF
      #   '';
      # }
    ];

    extraConfig = builtins.readFile ./init.vim;

    extraPython3Packages = (ps: with ps; [
      pynvim
      pylint
    ]);

    coc.enable = true;
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
          command = "rnix-lsp";
          filetypes = [ "nix" ];
        };
      };
    };
  };
}
