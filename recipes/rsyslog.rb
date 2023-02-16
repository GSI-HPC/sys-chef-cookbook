#
# extremly basic loghost setup
#

if node.has_key?('rsyslog')

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
    variables(
      filter: node['rsyslog']['filter'],
      tcp: node['rsyslog']['protocol'] == 'tcp'
    )
    only_if { node['rsyslog'].has_key?('server_ip') }
    notifies :restart, "service[rsyslog]"
  end
  rsyslog_major_version = %x[/usr/sbin/rsyslogd -v].lines.first.strip.gsub(/\Arsyslogd\s+(\d+).*\z/, '\1').to_i

  node['sys']['rsyslog']['loghosts'].each do |name, cfg|
    if rsyslog_major_version < 8
      Chef::Log.warn "rsyslog must be at least version 8, skipping config for loghost #{name}."
      next
    end
    priority_filter = cfg['priority_filter'] || '*.*'
    port = cfg['port'] || '514'
    protocol = cfg['protocol'] || 'tcp'
    stream_driver = false
    type = cfg['type'] || 'omfwd'
    if cfg['tls']
      port = cfg['port'] || '6514'
      ca_file = cfg['ca_file'] || '/etc/ssl/certs/ca-certificates.crt'
      if node['platform'] == 'debian' && node['platform_version'].to_i < 11 ||
          node['platform'] == 'ubuntu' && node['platform_version'].to_i < 20
        package 'rsyslog-gnutls'
        stream_driver = 'gtls'
      else
        package 'rsyslog-openssl'
        stream_driver = 'ossl'
      end
    end

    template "/etc/rsyslog.d/20-loghost-#{cfg['name']}.conf" do
      source 'etc_rsyslog.d_loghost-generic.conf.erb'
      owner 'root'
      group 'root'
      mode '0600'
      variables(
        priority_filter: priority_filter,
        target: cfg['target'] || cfg['target_ip'],
        port: port,
        protocol: protocol,
        stream_driver: stream_driver,
        ca_file: ca_file,
        tls: cfg['tls'] || false,
        type: type
      )
      only_if { cfg.has_key?('target_ip') || cfg.has_key?('target') }
      notifies :restart, 'service[rsyslog]'
    end
  end

  service "rsyslog" do
    supports :restart => true, :status => true
    action   :enable
  end

end
