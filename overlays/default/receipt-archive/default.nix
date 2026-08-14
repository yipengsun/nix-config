{
  writeShellApplication,
  atool,
  coreutils,
  zip,
}:
writeShellApplication {
  name = "receipt-archive";
  runtimeInputs = [
    atool
    coreutils
    zip
  ];
  text = builtins.readFile ./receipt-archive;
}
