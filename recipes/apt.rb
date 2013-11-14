#
# Cookbook Name:: sys
# Recipe:: apt
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

apt_update = "apt-get -qq update"
execute apt_update do
  action :nothing
end

# Default APT source file

unless node.sys.apt.sources.empty?
  template "/etc/apt/sources.list" do
    source "etc_apt_sources.list.erb"
    mode 644
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
    pref[:package] = '*' unless pref.has_key? 'package'
    sys_apt_preference name do
      package pref[:package]
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

# Manage APT keys
# Remove keys specified via attributes first
unless node.sys.apt[:keys].remove.empty?
  node.sys.apt[:keys].remove.each do |key|
    sys_apt_key key do
      action :remove
    end
  end
end
# Then add new keys from attributes
unless node.sys.apt[:keys].add.empty?
  node.sys.apt[:keys].add.each do |key|
    sys_apt_key key
  end
end

# add multiarch support if desired:
#  this is statically pinned to i386 on amd64 for now
execute 'dpkg --add-architecture i386' do   
  only_if { node[:sys][:apt][:multiarch] and node[:debian][:architecture] == 'amd64' }
  not_if  { node[:debian][:foreign_architectures].include?('i386') }
  notifies :run, "execute[#{apt_update}]", :immediately
end
