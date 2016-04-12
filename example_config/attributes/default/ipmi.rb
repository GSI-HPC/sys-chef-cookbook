# coding: iso-8859-15
default['sys']['ipmi'] = {
  'install_packages' => true,
  'overheat_protection' => {
    'enable' => true,
    # temperature thresholds in °C:
    'warn_threshold' => 45,
    'crit_threshold' => 50
  }
}
