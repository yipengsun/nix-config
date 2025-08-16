{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # MS prevents unofficial VS code builds from using cpptools :-(

    mutableExtensionsDir = false;

    profiles.default.enableUpdateCheck = false;
    profiles.default.enableExtensionUpdateCheck = false;

    profiles.default.userSettings = {
      "window.autoDetectColorScheme" = false;
      "window.autoDetectHighContrast" = false;

      "workbench.colorTheme" = "Dracula"; # FIXME: changed to 'Dracula Theme' in 2.25+
      "workbench.startupEditor" = "none";

      "editor.fontFamily" = "'FiraCode Nerd Font Mono', 'monospace', monospace";
      "editor.fontLigatures" = true;
      "editor.inlayHints.enabled" = "offUnlessPressed";

      "cmake.configureOnOpen" = false;
      "C_Cpp.intelliSenseEngine" = "disabled";

      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
    };

    profiles.default.keybindings = [
      {
        key = "ctrl+c";
        command = "-vscode-neovim.escape";
        when = "editorTextFocus && neovim.ctrlKeysInsert.c && neovim.init && neovim.mode != 'normal' && editorLangId not in 'neovim.editorLangIdExclusions'";
      }
    ];

    profiles.default.extensions =
      let
        isLinux = pkgs.stdenv.hostPlatform.isLinux;

        cppDebugging = (
          with pkgs.vscode-extensions; if isLinux then ms-vscode.cpptools else vadimcn.vscode-lldb
        );
      in
      with pkgs.vscode-extensions;
      [
        # ui and interactivity
        vscodevim.vim

        # FIXME: https://github.com/vscode-neovim/vscode-neovim/issues/2184
        #asvetliakov.vscode-neovim

        editorconfig.editorconfig

        github.copilot
        github.copilot-chat

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

        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance

        jnoortheen.nix-ide

        cppDebugging
      ];
  };
}
