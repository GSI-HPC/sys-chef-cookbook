#
# Cookbook Name:: sys
# Recipe:: apt
#
# Author:: Dennis Klein
# Author:: Victor Penso
#
# Copyright:: 2013, GSI HPC Department
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

apt_update = "apt-get -qq update"
execute apt_update do
  action :nothing
  # 100 means something went wrong: we don't want chef to fail completely in that case ...
  returns [ 0, 100 ]
end

# Default APT source file

unless node.sys.apt.sources.empty?
  template "/etc/apt/sources.list" do
    source "etc_apt_sources.list.erb"
    mode "644"
    variables :config => node.sys.apt.sources.gsub(/^ */,'')
    notifies :run, "execute[#{apt_update}]", :immediately
  end
end

# APT configuration

unless node.sys.apt.config.empty?
  node.sys.apt.config.each do |name,conf|
    sys_apt_conf name do
      config conf
    end
  end
end


unless node.sys.apt.preferences.empty?
  node.sys.apt.preferences.each do |name,pref|
    if pref.empty?
      sys_apt_preference name do
        action :remove
      end
      next
    end
    pkg = pref[:package] || '*'
    sys_apt_preference name do
      package pkg
      pin pref[:pin]
      priority pref[:priority]
    end
  end
end

unless node.sys.apt.repositories.empty?
  node.sys.apt.repositories.each do |name,conf|
    sys_apt_repository name do
      config conf
    end
  end
end

# ------
# Manage APT keys
# ------
# Then add new keys from attributes
unless node.sys.apt['keys'].add.empty?
  node.sys.apt['keys'].add.each_index do |i|
    sys_apt_key "#{i}: Deploy APT package signing key" do
      key node.sys.apt['keys'].add[i]
    end
  end
end
# Remove keys specified via attributes first
unless node.sys.apt['keys'].remove.empty?
  node.sys.apt['keys'].remove.each_index do |i|
    sys_apt_key "#{i}: Remove APT apckage signing key" do
      key node.sys.apt['keys'].remove[i]
      action :remove
    end
  end
end

# Install additional packages defined by attribute
unless node.sys.apt.packages.empty?
  node.sys.apt.packages.each do |pkg|
    package pkg
  end
end

# add multiarch support if desired:
#  this is statically pinned to i386 on amd64 for now
execute 'dpkg --add-architecture i386' do
  only_if { node['sys']['apt']['multiarch'] and node['debian']['architecture'] == 'amd64' }
  not_if  { node['debian']['foreign_architectures'].include?('i386') }
  notifies :run, "execute[#{apt_update}]", :immediately
end
