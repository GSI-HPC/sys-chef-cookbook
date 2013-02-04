Set Linux kernel variables in `/etc/sysctl.d/` and load them
immediately.

↪ `attributes/control.rb`  
↪ `recipes/control.rb`  
↪ `tests/roles/sys_control_test.rb`  

**Attribute**

Requires the configuration of `node.sys.control` with a
structure representing the `sysctl` format (see example).

**Examples**

    [...SNIP...]
    "sys" => {
      "control" => {
        "net.ipv6" => { "conf.all.disable_ipv6" => 1 },
        "net.ipv6.conf.default" => {
          "autoconf" => 0,
          "router_solicitations" => 0,
          "accept_ra_rtr_pref" => 0
        },
        "net.ipv4" => {
          "icmp_echo_ignore_broadcasts" => 1,
          "ip_forward" => 0
        },
        "kernal" => {
          "exec-shield" => 1,
          "randomize_va_space" => 1
        },
        "vm" => { "zone_reclaim_mode" => 0  }
      },
      [...SNIP...]
