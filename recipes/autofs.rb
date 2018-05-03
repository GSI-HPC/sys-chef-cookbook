# coding: utf-8
#
# Cookbook Name:: sys
# Recipe:: autofs
#
# Copyright 2013 -2018 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
# Authors:
#  Victor Penso      2013 - 2015
#  Christopher Huhn  2013 - 2018
#  Matthias Pausch   2013 - 2017
#  Bastian Neuburger 2015
#  Dennis Klein      2015
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

return if node['sys']['autofs']['maps'].empty? &&
          node['sys']['autofs']['ldap'].empty?

package 'autofs'

node['sys']['autofs']['maps'].each_key do |mountpoint|
  directory mountpoint do
    recursive true
    not_if { File.exist?(mountpoint) }
  end
end

template '/etc/auto.master' do
  source 'etc_auto.master.erb'
  mode "0644"
  variables(
    :maps => node['sys']['autofs']['maps']
  )
  notifies :reload, 'service[autofs]'
end

# on Jessie the maps go to /etc/auto.master.d/
if node['platform_version'].to_i >= 8

  directory '/etc/auto.master.d'

  delete = Dir.glob('/etc/auto.master.d/*')

  keep = node['sys']['autofs']['maps'].keys.map{|path| "/etc/auto.master.d/#{path[1..-1].gsub(/\//,'_').downcase}.autofs"}

  (delete - keep).each do |f|
    file f do
      action :delete
    end
  end

  node['sys']['autofs']['maps'].each do |path, map|
    name = path[1..-1].gsub(/\//,'_').downcase
    template "/etc/auto.master.d/#{name}.autofs" do
      source 'etc_auto.master.d.erb'
      mode "0644"
      variables(
        :map => map,
        :path => path
      )
        notifies :reload, 'service[autofs]', :delayed
    end
  end
end

if ! node['sys']['autofs']['ldap'].empty? && File.exist?('/usr/bin/kinit')

  package "autofs-ldap" # also pulls autofs

  sys_wallet "autofsclient/#{node['fqdn']}" do
    place "/etc/autofs.keytab"
  end

  template "/etc/autofs_ldap_auth.conf" do
    source "etc_autofs_ldap_auth.conf.erb"
    mode "0600"
    notifies :restart, 'service[autofs]', :delayed
  end

  template "/etc/default/autofs" do
    source "etc_default_autofs.erb"
    mode "0644"
    begin
      if node['sys']['autofs']['ldap']['browsemode']
        browsemode = "yes"
      else
        browsemode = "no"
      end
    rescue NoMethodError
      browsemode = "no"
    end

    variables({
      :uris => node['sys']['autofs']['ldap']['servers'],
      :searchbase => node['sys']['autofs']['ldap']['searchbase'],
      :browsemode => browsemode,
      :logging    => node['sys']['autofs']['logging']
    })
    notifies :restart, 'service[autofs]', :delayed
  end

  if node['platform_version'].to_i >= 9

    sys_systemd_unit 'autofs.service' do
      config({
        'Unit' => {
          'Description' => 'Automounts filesystems on demand',
          'After' => 'network.target ypbind.service sssd.service'\
                     ' network-online.target remote-fs.target'\
                     'k5start-autofs.service',
          'BindsTo' => 'k5start-autofs.service',
          'Requires' => 'network-online.target',
          'Before' => 'xdm.service',
        },
        'Service' => {
          'Type' => 'forking',
          'PIDFile' => '/var/run/autofs.pid',
          'EnvironmentFile' => '-/etc/default/autofs',
          'ExecStart' => '/usr/sbin/automount $OPTIONS'\
                         ' --pid-file /var/run/autofs.pid',
          'ExecReload' => '/bin/kill -HUP $MAINPID',
          'TimeoutSec' => '180',
        },
        'Install' => {
          'WantedBy' => 'gsi-remote.target',
        }
      })
      notifies :restart, 'service[autofs]'
    end

    sys_systemd_unit 'k5start-autofs.service' do
      config({
        'Unit' => {
          'Description' => 'Maintain Ticket-Cache for autofs',
          'Documentation' => 'man:k5start(1) man:autofs(8)',
          'After' => 'network-online.target',
          'Requires' => 'network-online.target',
          'Before' => 'autofs.service',
        },
        'Service' => {
          'Type' => 'forking',
          'ExecStart' => '/usr/bin/k5start -b -L -F -f /etc/autofs.keytab'\
                         ' -K 60 -k /tmp/krb5cc_autofs -U -x',
          'Restart' => 'always',
          'RestartSec' => '5',
        },
        'Install' => {
          'WantedBy' => 'gsi-remote.target',
        }
      })
      notifies :restart, 'service[k5start-autofs]'
    end

    service 'k5start-autofs' do
      supports :restart => true, :reload => true
      action [:enable, :start]
    end

  else
    cookbook_file "/etc/init.d/autofs" do
      source "etc_init.d_autofs"
      mode "0755"
      notifies :restart, 'service[autofs]', :delayed
    end
  end
end

service 'autofs' do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
