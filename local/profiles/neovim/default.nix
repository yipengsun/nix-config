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

      # syntax
      vim-nix

      # ide
      { plugin = coc-nvim; config = builtins.readFile ./coc-nvim.vim; }
      coc-python
      coc-pyright
      coc-pairs
      coc-texlab
      coc-vimlsp
      coc-yaml
      coc-lua

      # ui
      { plugin = dracula-vim; config = "colorscheme dracula"; }
      vim-airline
      { plugin = vim-airline-themes; config = "let g:airline_theme='dracula'"; }
    ];

    extraConfig = builtins.readFile ./init.vim;

    coc.enable = true;
    coc.settings = {
      "python.linting.flake8Enabled" = true;
      languageserver = {
        ccls = {
          command = "ccls";
          filetypes = [ "c" "cpp" "objc" "objcpp" ];
          rootPatterns = [ ".ccls" "compile_commands.json" ];
          initializationOptions = {
            "cache.directory" = "/tmp/ccls";
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
