{
  self,
  lib,
  ...
}:
{
  perSystem =
    { system, pkgs, ... }:
    let
      mkHostEvalCheck =
        name: systemDrv:
        pkgs.runCommand "eval-${name}"
          {
            evaluatedDrv = builtins.unsafeDiscardStringContext systemDrv.drvPath;
          }
          ''
            printf '%s\n' "$evaluatedDrv" > "$out"
          '';

      mkLuaSyntaxCheck =
        name: sources:
        pkgs.runCommand "lua-syntax-${name}"
          {
            nativeBuildInputs = [ pkgs.lua5_3 ];
          }
          ''
            ${lib.concatMapStringsSep "\n" (source: "luac -p ${lib.escapeShellArg (toString source)}") sources}
            touch "$out"
          '';

      forCurrentSystem = lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system);
      currentHosts = forCurrentSystem (self.nixosConfigurations // self.darwinConfigurations);

      nixosChecks = lib.mapAttrs' (
        name: host:
        lib.nameValuePair "host-${name}" (mkHostEvalCheck name host.config.system.build.toplevel)
      ) (forCurrentSystem self.nixosConfigurations);

      darwinChecks = lib.mapAttrs' (
        name: host: lib.nameValuePair "host-${name}" (mkHostEvalCheck name host.system)
      ) (forCurrentSystem self.darwinConfigurations);

      luaChecks = lib.mapAttrs' (
        name: host:
        let
          home = host.config.home-manager.users.syp;
          neovimLuaPlugins = builtins.filter (
            plugin: (plugin.type or null) == "lua"
          ) home.programs.neovim.plugins;
          neovimSources = lib.imap0 (
            index: plugin: pkgs.writeText "neovim-${name}-${toString index}.lua" plugin.config
          ) neovimLuaPlugins;
          awesomeSources =
            lib.optional home.awesome-wm-config.enable
              home.xdg.configFile."awesome/rc.lua".source;
          weztermSources = lib.optional home.programs.wezterm.enable (
            pkgs.writeText "wezterm-${name}.lua" home.programs.wezterm.extraConfig
          );
        in
        lib.nameValuePair "lua-generated-${name}" (
          mkLuaSyntaxCheck name (neovimSources ++ awesomeSources ++ weztermSources)
        )
      ) currentHosts;
    in
    {
      checks = nixosChecks // darwinChecks // luaChecks;
    };
}
