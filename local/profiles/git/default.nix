{
  # tig config to resolve contrast issues w/ dracula
  xdg.configFile."tig/config".text = ''
    # color default         white   black
    color   cursor          black   green
    color   search-result   black   yellow
    # color author          green   black
    # color status          green   black
    color   line-number     red     black
    color   title-focus     black   yellow
    color   title-blur      black   magenta
    # Diff colors
    color diff-header       yellow  default
    color diff-index        blue    default
    color diff-chunk        magenta default
    color "Reported-by:"    green   default
    # View-specific color
    color tree.date         black   cyan    bold
  '';

  programs.git = {
    enable = true;

    extraConfig = {
      pull.rebase = false;
      core.editor = "nvim";
      core.pager = "less";
      merge.tool = "vimdiff";
      branch.autosetuprebase = "always";

      user.name = "Yipeng Sun";
      user.email = "syp@umd.edu";
    };

    aliases = {
      a = "add -p";
      co = "checkout";
      cob = "checkout -b";
      f = "fetch -p";
      c = "commit";
      p = "push";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      r = "restore";
      rs = "restore --staged";
      st = "status -sb";

      # reset
      soft = "reset --soft";
      hard = "reset --hard";
      s1ft = "soft HEAD~1";
      h1rd = "hard HEAD~1";

      # logging
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog =
        "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog =
        "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";

      # delete merged branches
      bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
    };
  };
}
