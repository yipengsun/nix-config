{
  self,
  pkgs,
  config,
  ...
}:
let
  ip = "${pkgs.iproute2}/bin/ip";
  iptables = "${pkgs.iptables}/bin/iptables";

  cleanupLegacyFirewall = ''
    while ${iptables} -t mangle -C PREROUTING -p tcp -m socket -j DIVERT 2>/dev/null; do
      ${iptables} -t mangle -D PREROUTING -p tcp -m socket -j DIVERT
    done
    ${iptables} -t mangle -F DIVERT 2>/dev/null || true
    ${iptables} -t mangle -X DIVERT 2>/dev/null || true
  '';

  cleanupFirewall = ''
    while ${iptables} -t mangle -C PREROUTING -p tcp -m socket -j V2RAY_DIVERT 2>/dev/null; do
      ${iptables} -t mangle -D PREROUTING -p tcp -m socket -j V2RAY_DIVERT
    done
    while ${iptables} -t mangle -C PREROUTING -j V2RAY 2>/dev/null; do
      ${iptables} -t mangle -D PREROUTING -j V2RAY
    done
    while ${iptables} -t mangle -C OUTPUT -j V2RAY_MASK 2>/dev/null; do
      ${iptables} -t mangle -D OUTPUT -j V2RAY_MASK
    done

    for chain in V2RAY_DIVERT V2RAY V2RAY_MASK; do
      ${iptables} -t mangle -F "$chain" 2>/dev/null || true
      ${iptables} -t mangle -X "$chain" 2>/dev/null || true
    done

    while ${ip} rule del fwmark 1 table 100 2>/dev/null; do :; done
    ${ip} route del local 0.0.0.0/0 dev lo table 100 2>/dev/null || true
  '';
in
{
  # additional tooling for debugging
  environment.systemPackages = with pkgs; [
    traceroute
    v2ray
  ];

  # use v2ray as the proxy (this supports tproxy)
  services.v2ray.enable = true;
  age.secrets.v2ray_tproxy = {
    file = "${self}/secrets/v2ray_tproxy.age";
    path = "/etc/nixos/v2ray.json";
    mode = "0400";
  };
  services.v2ray.configFile = config.age.secrets.v2ray_tproxy.path;

  # override file limits
  systemd.services.v2ray.serviceConfig = {
    LimitNPROC = 500;
    LimitNOFILE = 1000000;
  };

  # enable forwarding for both IPv4 & IPv6
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  #boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # setup iptables mangling rules
  #   main guide: https://guide.v2fly.org/app/tproxy.html
  #   related doc: https://www.kernel.org/doc/Documentation/networking/tproxy.rst
  networking.firewall.extraCommands = ''
    ${cleanupLegacyFirewall}
    ${cleanupFirewall}

    ${iptables} -t mangle -N V2RAY_DIVERT
    ${iptables} -t mangle -I PREROUTING -p tcp -m socket -j V2RAY_DIVERT
    ${iptables} -t mangle -A V2RAY_DIVERT -j MARK --set-mark 1
    ${iptables} -t mangle -A V2RAY_DIVERT -j ACCEPT

    ${ip} rule add fwmark 1 table 100
    ${ip} route add local 0.0.0.0/0 dev lo table 100

    ${iptables} -t mangle -N V2RAY
    ${iptables} -t mangle -A V2RAY -j RETURN -m mark --mark 0xff
    ${iptables} -t mangle -A V2RAY -d 127.0.0.1/32 -j RETURN
    ${iptables} -t mangle -A V2RAY -p udp -j TPROXY --on-ip 127.0.0.1 --on-port 5280 --tproxy-mark 1
    ${iptables} -t mangle -A V2RAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 5280 --tproxy-mark 1
    ${iptables} -t mangle -A PREROUTING -j V2RAY

    ${iptables} -t mangle -N V2RAY_MASK
    ${iptables} -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff
    ${iptables} -t mangle -A V2RAY_MASK -d 10.0.0.0/8 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 10.0.0.0/8 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 169.254.0.0/16 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 169.254.0.0/16 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 172.16.0.0/12 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 172.16.0.0/12 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 192.168.0.0/16 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 192.168.0.0/16 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 240.0.0.0/4 -p tcp -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 240.0.0.0/4 -p udp ! --dport 53 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN
    ${iptables} -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1
    ${iptables} -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1
    ${iptables} -t mangle -A OUTPUT -j V2RAY_MASK
  '';
  networking.firewall.extraStopCommands = cleanupFirewall;
}
