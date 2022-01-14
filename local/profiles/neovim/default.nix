{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      dracula-vim
    ];

    coc.enable = true;
    coc.settings = {
      "python.linting.flake8Enabled" = true;
      languageserver = {
        ccls = {
          command = "ccls";
          filetypes = [ "c" "cpp" "objc" "objcpp" ];
          rootPatterns = [ ".ccls" "compile_commands.json" ];
          initializationOptions = {
            "cache.directory" = "tmp/ccls";
          };
        };
      };
    };
  };
}
