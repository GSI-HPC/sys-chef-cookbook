#
# install smartmontools and configure smartd
#

enable = node['sys']['smartd']['enable']

if enable && node['virtualization']['role'] == 'guest'
  enable = false
  log 'According to Ohai this is a VM - not enabling smartd'
end

if enable
  package 'smartmontools'

  smartd_service_name = "smartmontools"

  if node['platform_version'].to_i >= 8
    smartd_service_name = "smartd"
  end

  service smartd_service_name do
    action [ :enable, :start ]
    # don't crash chef-client if smartd does not start
    ignore_failure true
  end

  template '/etc/default/smartmontools' do
    source 'etc_default_smartmontools.erb'
    variables(
      enable: enable
    )
    notifies :restart, "service[#{smartd_service_name}]"
  end

  template '/etc/smartd.conf' do
    source 'etc_smartd.conf.erb'
    variables(
      mailto: node['sys']['smartd']['mailto']
    )
    notifies :reload, "service[#{smartd_service_name}]"
  end
end
