{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Store direnvs centrally
    stdlib = ''
      : ''${XDG_CACHE_HOME:=''$HOME/.cache}
      pwd_hash=''$(echo -n ''$PWD | sha1sum | cut -d ' ' -f 1)
      direnv_layout_dir=''$XDG_CACHE_HOME/direnv/''$pwd_hash
    '';
  };
}
