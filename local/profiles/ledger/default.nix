{ pkgs, ... }:
{
  home.packages = [ pkgs.ledger ];

  home.file.".ledgerrc".text = ''
    --file ~/data/ledger/syp.dat
  '';
}
