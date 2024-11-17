{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    userSettings = {
      "window.autoDetectColorScheme" = false;

      "workbench.colorTheme" = "Dracula Theme";
      "workbench.startupEditor" = "none";

      "editor.fontFamily" = "'FiraCode Nerd Font Mono', 'monospace', monospace";
      "editor.fontLigatures" = true;
      "editor.inlayHints.enabled" = "offUnlessPressed";

      "cmake.configureOnOpen" = false;
      "C_Cpp.intelliSenseEngine" = "disabled";

      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
    };

    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    extensions = with pkgs.vscode-extensions; [
      # ui and interactivity
      asvetliakov.vscode-neovim
      github.copilot # copilot-chat is deprecated, don't use it
      dracula-theme.theme-dracula

      # build
      twxs.cmake
      ms-vscode.cmake-tools

      # formatters
      ms-python.black-formatter

      # language servers
      llvm-vs-code-extensions.vscode-clangd
      rust-lang.rust-analyzer

      # language support
      yzhang.markdown-all-in-one

      ms-vscode.cpptools # for C++ debugging

      ms-python.debugpy
      ms-python.python
    ];
  };
}
