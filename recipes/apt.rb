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

#apt_update = "apt-get -qq update"
#execute apt_update do
#  action :nothing
#end

# APT configuration

unless node.sys.apt.config.empty?
  node.sys.apt.config.each do |name,conf|
    sys_apt_conf name do
      config conf
    end
  end
end

include_recipe 'apt'

node[:sys][:apt][:srcs].each_pair do | name, repo |
  
  # skip unless explicitely enabled:
  next unless node[:sys][:apt][:active_sources].include?(name)
  
  apt_repository name do

    method = repo[:method] || 'http'
    server = repo[:server] || node[:sys][:apt][:default_server] || 'ftp.debian.org'
    path   = repo[:path]   || node[:sys][:apt][:default_path]   || 'ftp.debian.org''/debian'
    uri method + '://' + server + path
    distribution repo[:distrib] || node[:lsb][:codename]
    components repo[:components] || %w{main contrib non-free}
    deb_src true unless repo[:no_sources]
    # key ... - not yet implemented
  end

end

# add multiarch support if desired:
#  this is statically pinned to i386 on amd64 for now
execute 'dpkg --add-architecture i386' do   
  only_if { node[:sys][:apt][:multiarch] and node[:debian][:architecture] == 'amd64' }
  not_if  { node[:debian][:foreign_architectures].include?('i386') }
  notifies :run, "execute[apt-get update]", :immediately
end

package 'apt-file'
