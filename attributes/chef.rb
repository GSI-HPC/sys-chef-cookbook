default_unless['sys']['chef']['product_name'] = ChefUtils::Dist::Infra::SHORT
default_unless['sys']['chef']['config_dir'] =
  "/etc/#{node['sys']['chef']['product_name']}"

# invocation interval in seconds
default_unless['sys']['chef']['interval']       = 1800
# invocation will be postponed by a random value up to this number of seconds:
default_unless['sys']['chef']['splay']          = 300
default_unless['sys']['chef']['client_key'] =
  "#{node['sys']['chef']['config_dir']}/client.pem"
default_unless['sys']['chef']['validation_key'] =
  "#{node['sys']['chef']['config_dir']}/validation.pem"
default_unless['sys']['chef']['validation_client_name'] =
  "#{node['sys']['chef']['product_name']}-validator"
# legacy server attribute
default_unless['chef']['server']                = {}

default_unless['sys']['chef']['use_syslog']     = false
default_unless['sys']['chef']['log_level']      = ':info'
default_unless['sys']['chef']['group']          = 'adm'
default_unless['sys']['chef']['verify_ssl']     = 'all'

if node['platform_family'] == 'debian'
  default_unless['sys']['chef']['trusted_certs_dir'] = '/etc/ssl/certs'
end

default_unless['sys']['chef']['restart_via_cron'] = false

if node['platform_family'] == 'rhel'
  default_unless['sys']['chef']['init_style'] = 'systemd-timer'
end
