#
# Cookbook Name:: sys
# Recipe:: autofs
#
# Copyright 2013, Victor Penso
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

if ! node['sys']['autofs']['maps'].empty? && node['sys']['autofs']['ldap'].empty?

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

  #  node['sys']['autofs']['maps'].each_key do |path|
  #    directory path do
  #      recursive true
  #    end
  #  end

  service 'autofs' do
    supports :restart => true, :reload => true
  end
end

if ! node['sys']['autofs']['ldap'].empty? && File.exist?('/usr/bin/kinit')

  package "autofs-ldap" # also pulls autofs

  sys_wallet "autofsclient/#{node['fqdn']}" do
    place "/etc/autofs.keytab"
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

  template "/etc/auto.master" do
    source 'etc_auto.master.erb'
    mode "0644"
    variables(
      :maps => (node['platform_version'].to_i < 8)?node['sys']['autofs']['maps']:{}
    )
    notifies :reload, 'service[autofs]'
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
    rescue
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
    cookbook_file '/etc/systemd/system/autofs.service' do
      source 'etc_systemd_system_autofs.service'
      mode '0644'
      notifies :run, 'execute[systemctl daemon-reload]'
      notifies :restart, 'service[autofs]'
    end

    cookbook_file '/etc/systemd/system/k5start-autofs.service' do
      source 'etc_systemd_system_k5start-autofs.service'
      mode '0644'
      notifies :run, 'execute[systemctl daemon-reload]'
      notifies :restart, 'service[k5start-autofs]'
    end

    service 'k5start-autofs' do
      supports :restart => true, :reload => true
      action [:enable, :start]
    end

    execute 'systemctl daemon-reload' do
      action :nothing
      command '/bin/systemctl daemon-reload'
    end
  else
    cookbook_file "/etc/init.d/autofs" do
      source "etc_init.d_autofs"
      mode "0755"
      notifies :restart, 'service[autofs]', :delayed
    end
  end

  service 'autofs' do
    supports :restart => true, :reload => true
    action [:enable, :start]
  end
end
