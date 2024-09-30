{ pkgs, ... }: {
  home.packages = with pkgs; [
    ledger
    receipt-archive
  ];

  home.file.".ledgerrc".text = ''
    --file ~/data/ledger/syp.dat
  '';
}
