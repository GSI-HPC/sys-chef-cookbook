#
# extremly basic loghost setup
#

if node['rsyslog'].has_key?('server_ip') and !node['rsyslog']['server_ip'].nil?

  package "rsyslog"

  # Include a complete rsyslog config file:
  # 1) set log msgs rate limiting
  # 2) all the mail.* event log will be directed only on /var/log/mail.*
  template '/etc/rsyslog.conf' do
    source 'etc_rsyslog.conf.erb'
    owner "root"
    group "root"
    mode "0644"
    variables(
	      :ratelimit_burst => node['sys']['rsyslog']['ratelimit_burst'],
	      :ratelimit_interval => node['sys']['rsyslog']['ratelimit_interval']
    )
    notifies :restart, "service[rsyslog]"
  end

  # Configuration file for the remote loghost:
  template '/etc/rsyslog.d/loghost.conf' do
    source 'etc_rsyslog.d_loghost.conf.erb'
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, "service[rsyslog]"
  end

  service "rsyslog" do
    supports :restart => true, :status => true
    action   [:enable, :start]
  end

end
