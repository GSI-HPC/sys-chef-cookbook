#
# Cookbook Name:: sys
# Recipe:: banner
#
# Copyright 2012-2013, Victor Penso
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

unless node.sys.banner.message.empty?
  template '/etc/motd' do
    source 'etc_motd.erb'
    mode 0644
    variables(
      :header => node.sys.banner.header,
      :message => node.sys.banner.message,
      :footer => node.sys.banner.footer
    )
  end
end

if node.sys.banner.info

  package 'lsb-release'

  template '/etc/profile.d/info.sh' do
    source 'etc_profile.d_info.sh.erb'
    mode 0755
  end

end
