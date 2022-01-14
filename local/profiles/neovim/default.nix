{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # misc
      vim-fugitive
      {
        plugin = editorconfig-nvim;
        config = ''
          let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
          au FileType gitcommit let b:EditorConfig_disable = 1
        '';
      }
      nvim-autopairs
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
          let g:localvimrc_sandbox=0
          let g:localvimrc_persistent=2
        '';
      }
      delimitMate
      { plugin = vim-pandoc; config = "let g:pandoc#syntax#conceal#use=0"; }

      # syntax
      vim-nix
      vim-ledger
      vim-pandoc-syntax

      # ide
      { plugin = coc-nvim; config = builtins.readFile ./coc-nvim.vim; }
      coc-python
      coc-pyright
      coc-pairs
      coc-texlab
      coc-vimtex
      coc-vimlsp
      coc-yaml
      coc-lua
      vim-lsp-cxx-highlight
      {
        plugin = vimtex;
        config = ''
          let g:vimtex_fold_enabled=1
          let g:tex_conceal=""
          let g:tex_flavor="latex"
        '';
      }
      vim-python-pep8-indent
      {
        plugin = nerdcommenter;
        config = ''
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
              execute fl . ','. ll .'call NERDComment("n", "Toggle")'
          endfunc
          nnoremap ,h :call AutoHead()<CR>
        '';
      }
      {
        plugin = vimwiki;
        config = ''
          let g:vimwiki_global_ext=0
          let g:vimwiki_hl_headers=1
          let g:vimwiki_camel_case=0
          let g:vimwiki_hl_cb_checked=1
          let g:vimwiki_CJK_length=1

          if isdirectory($HOME.'/data')
              let g:vimwiki_list=[{
                          \ 'path': '~/data/wiki',
                          \ 'path_html': '~/data/wiki/html',
                          \ }]
          endif
          nnoremap \ty :VimwikiToggleListItem<CR>
        '';
      }
      { plugin = vim-clang-format; config = "let g:clang_format#detect_style_file=1"; }

      # ui
      {
        plugin = dracula-vim;
        config = ''
          colorscheme dracula
          set termguicolors
        '';
      }
      vim-airline
      { plugin = vim-airline-themes; config = "let g:airline_theme='dracula'"; }
      { plugin = tagbar; config = "nnoremap <silent><F2> :TagbarToggle<CR>"; }
    ];

    extraConfig = builtins.readFile ./init.vim;

    extraPackages = [ pkgs.python ];
    extraPython3Packages = (ps: with ps; [
      jedi
      flake8
      pylint
    ]);

    coc.enable = true;
    coc.settings = {
      "python.linting.flake8Enabled" = true;
      languageserver = {
        ccls = {
          command = "ccls";
          filetypes = [ "c" "cpp" "objc" "objcpp" ];
          rootPatterns = [ ".ccls" "compile_commands.json" ];
          initializationOptions = {
            cache = {
              directory = "/tmp/ccls";
            };
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
