{ config, ... }:
{
  services.nixseparatedebuginfod.enable = !config.wsl.enable;

  # allow gdb attaching to arbitrary process
  boot.kernel.sysctl =
    if (config.wsl.enable) then { }
    else { "kernel.yama.ptrace_scope" = "0"; };
}
