#
# Cookbook Name:: sys
# Recipe:: nfs
#
# Copyright 2016, Matthias Pausch
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

unless node['sys']['nfs'].empty?

  template '/etc/default/nfs-common' do
    source 'etc_default_nfs-common.erb'
    user 'root'
    owner 'root'
    mode '0644'
    notifies :restart, 'service[nfs-common]', :delayed
  end

  # Comments in systemctl-src say that update-rc.d does not provide
  # information wheter a service is enabled or not and always returns
  # false.  Work around that.
  actions = [:start]
  actions << :enable if Dir.glob('/etc/rcS.d/*nfs-common*').empty?

  service 'nfs-common' do
    action actions
    supports :restart => true
    # nfs-common unit is masked on Stretch
    only_if { node['platform_version'].to_i < 9}
  end

end
