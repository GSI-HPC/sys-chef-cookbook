#
# Recipe for popularity-contest setup
#

unless node['sys']['popcon'].empty?

  # configuration via debconf would be nice but
  # 1. only run by Chef during install
  # 2. existing config file takes precedence over debconf
  package 'popularity-contest'

  # we need a host id:
  unless node['sys']['popcon']['hostid']
    begin
      # read the current hostid from the config file:
      node.normal['sys']['popcon']['hostid'] =
        File.open('/etc/popularity-contest.conf').grep(/^MY_HOSTID=/)[0].scan(/[0-9a-f]{32}/)[0]
    rescue Errno::ENOENT, NoMethodError
      require 'securerandom'
      # generate a hostid and store it on the Chef server:
      node.normal['sys']['popcon']['hostid'] = SecureRandom.uuid.gsub('-','')
    end
  end

  template '/etc/popularity-contest.conf' do
    source 'etc_popularity-contest.conf.erb'
    mode 0644
    variables(
      hostid: node['sys']['popcon']['hostid'],
      participate: node['sys']['popcon']['enable'],
      # String here - possible values: yes|no|maybe
      encrypt: 'yes'
    )
  end

end
