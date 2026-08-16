{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  ip = "${pkgs.iproute2}/bin/ip";
  iptables = "${pkgs.iptables}/bin/iptables";

  policy = {
    mark = "1";
    bypassMark = "0xff";
    routeTable = "100";
    localRoute = "0.0.0.0/0";

    tproxyAddress = "127.0.0.1";
    tproxyBypassCidr = "127.0.0.1/32";
    tproxyPort = "5280";

    dnsPort = "53";
    udpDnsProxyCidrs = [
      "10.0.0.0/8"
      "169.254.0.0/16"
      "172.16.0.0/12"
      "192.168.0.0/16"
      "224.0.0.0/4"
      "240.0.0.0/4"
    ];
    alwaysBypassCidr = "255.255.255.255/32";
  };

  proxyProtocols = [
    "udp"
    "tcp"
  ];
  cidrReturnProtocols = [
    "tcp"
    "udp"
  ];

  mkProtocolRules = protocols: mkRule: lib.concatMapStringsSep "\n" mkRule protocols;

  tproxyRules = mkProtocolRules proxyProtocols (
    protocol:
    "${iptables} -t mangle -A V2RAY -p ${protocol} -j TPROXY"
    + " --on-ip ${policy.tproxyAddress}"
    + " --on-port ${policy.tproxyPort}"
    + " --tproxy-mark ${policy.mark}"
  );

  outputCidrReturnRules = lib.concatMapStringsSep "\n" (
    cidr:
    mkProtocolRules cidrReturnProtocols (
      protocol:
      "${iptables} -t mangle -A V2RAY_MASK -d ${cidr} -p ${protocol}${
        lib.optionalString (protocol == "udp") " ! --dport ${policy.dnsPort}"
      } -j RETURN"
    )
  ) policy.udpDnsProxyCidrs;

  outputMarkRules = mkProtocolRules proxyProtocols (
    protocol: "${iptables} -t mangle -A V2RAY_MASK -p ${protocol} -j MARK --set-mark ${policy.mark}"
  );

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

    while ${ip} rule del fwmark ${policy.mark} table ${policy.routeTable} 2>/dev/null; do :; done
    ${ip} route del local ${policy.localRoute} dev lo table ${policy.routeTable} 2>/dev/null || true
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

  # This profile does not enable IP forwarding; its transparent-proxy policy is IPv4-only.

  # Set up IPv4 iptables mangle and policy-routing rules.
  #   main guide: https://guide.v2fly.org/app/tproxy.html
  #   related doc: https://www.kernel.org/doc/Documentation/networking/tproxy.rst
  networking.firewall.extraCommands = ''
    ${cleanupLegacyFirewall}
    ${cleanupFirewall}

    ${iptables} -t mangle -N V2RAY_DIVERT
    ${iptables} -t mangle -I PREROUTING -p tcp -m socket -j V2RAY_DIVERT
    ${iptables} -t mangle -A V2RAY_DIVERT -j MARK --set-mark ${policy.mark}
    ${iptables} -t mangle -A V2RAY_DIVERT -j ACCEPT

    ${ip} rule add fwmark ${policy.mark} table ${policy.routeTable}
    ${ip} route add local ${policy.localRoute} dev lo table ${policy.routeTable}

    ${iptables} -t mangle -N V2RAY
    ${iptables} -t mangle -A V2RAY -j RETURN -m mark --mark ${policy.bypassMark}
    ${iptables} -t mangle -A V2RAY -d ${policy.tproxyBypassCidr} -j RETURN
    ${tproxyRules}
    ${iptables} -t mangle -A PREROUTING -j V2RAY

    ${iptables} -t mangle -N V2RAY_MASK
    ${iptables} -t mangle -A V2RAY_MASK -j RETURN -m mark --mark ${policy.bypassMark}
    ${outputCidrReturnRules}
    ${iptables} -t mangle -A V2RAY_MASK -d ${policy.alwaysBypassCidr} -j RETURN
    ${outputMarkRules}
    ${iptables} -t mangle -A OUTPUT -j V2RAY_MASK
  '';
  networking.firewall.extraStopCommands = cleanupFirewall;
}
