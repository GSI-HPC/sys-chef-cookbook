#
# extremly basic loghost setup
#

if node[:rsyslog].has_key?('server_ip')

  package "rsyslog"

  loghost_line = "*.*\t@"
  loghost_line += '@' if node['rsyslog']['protocol'] == 'tcp'
  loghost_line += node[:rsyslog][:server_ip]
  if node['rsyslog'].has_key?('port')
    loghost_line += node['rsyslog']['port'] unless node['rsyslog']['port'] == 514
  end

  # forward everything to the loghost:
  file '/etc/rsyslog.d/loghost.conf' do
    content  "#{loghost_line}\n"
    notifies :restart, "service[rsyslog]"
  end

  service "rsyslog" do
    supports :restart => true, :status => true
    action   [:enable, :start]
  end

end
