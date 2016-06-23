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

  service 'smartmontools' do
    action [ :enable, :start ]
  end

  template '/etc/default/smartmontools' do
    source 'etc_default_smartmontools.erb'
    variables(
      enable: enable
    )
    notifies :restart, 'service[smartmontools]'
  end

  template '/etc/smartd.conf' do
    source 'etc_smartd.conf.erb'
    variables(
      mailto: node['sys']['smartd']['mailto']
    )
    notifies :reload, 'service[smartmontools]'
  end
end
