{
  # allow gdb attaching to arbitrary process
  boot.kernel.sysctl."kernel.yama.ptrace_scope" = "0";
}
