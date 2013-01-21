name "sys_control_test"
description "Use to test the [sys::control] recipe."
run_list( "recipe[sys]" )
default_attributes(
  "sys" => {
    "control" => {
      "net.ipv4" => {
        "icmp_echo_ignore_broadcasts" => 1,
        "icmp_ignore_bogus_error_responses" => 1,
        "tcp_syncookies" => 1
      },
      "net.ipv4.conf" => {
        "all.log_martians" => 1,
        "default.log_martians" => 1,
        "all.accept_source_route" => 0,
        "default.accept_source_route" => 0
      },
      "kernal" => {
        "exec-shield" => 1,
        "randomize_va_space" => 1
      },
      "net.ipv6.conf.default" => {
        "autoconf" => 0,
        "router_solicitations" => 0,
        "accept_ra_rtr_pref" => 0,
        "accept_ra_pinfo" => 0,
        "accept_ra_defrtr" => 0,
        "dad_transmits" => 0,
        "max_addresses" => 1
      }
    }
  }
)
