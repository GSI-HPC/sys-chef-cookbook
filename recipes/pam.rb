#
# Cookbook Name:: sys
# Recipe:: pam
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

unless node.sys.pam.access.empty?
  template '/etc/security/access.conf' do
    source 'etc_security_access.conf.erb'
    owner 'root'
    group 'root'
    mode 0600
    variables :rules => node.sys.pam.access
  end
end

unless node.sys.pam.limits.empty?
  template '/etc/security/limits.conf' do
    source 'etc_security_limits.conf.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables :rules => node.sys.pam.limits
  end
end

unless node.sys.pam.pamd.empty?
  node.sys.pam.pamd.each do |file, contents|
    template "/etc/pam.d/#{file}" do
      source 'etc_pam.d_file.erb'
      owner 'root'
      group 'root'
      mode 0644
      variables(
        :rules => contents,
        :filename => file
      )
    end
  end
end

