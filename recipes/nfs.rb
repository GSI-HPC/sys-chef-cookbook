#
# Cookbook:: sys
# Recipe:: nfs
#
# Copyright:: 2016-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch    <m.pausch@gsi.de>
#  Christopher Huhn   <c.huhn@gsi.de>
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

return if node['sys']['nfs'].empty?

package 'nfs-common'

if debian_version >= 12
  # Bookworm switched to /etc/nfs.conf(.d/)

  template '/etc/nfs.conf.d/gssd.conf' do
    helpers(Sys::Harry)
    source 'harry.erb'
    variables(
      config: {
        gssd: {
          verbosity: 1,
          'rpc-verbosity' => 1
        }
      }
    )
  end
else

  # this ressource has a different name to allow
  #   co-existance with the nfs cookbook
  template '[sys] /etc/default/nfs-common' do
    path     '/etc/default/nfs-common'
    source   'etc_default_nfs-common.erb'
    user     'root'
    owner    'root'
    mode     '0644'
  end

  # nfs-common unit is masked on Stretch
  if debian_version < 9
    # Comments in systemctl-src say that update-rc.d does not provide
    # information wheter a service is enabled or not and always returns
    # false.  Work around that.
    actions = [:start]
    actions << :enable if Dir.glob('/etc/rcS.d/*nfs-common*').empty?

    service 'nfs-common' do
      action actions
      supports :restart => true
      subscribes :restart, 'template[[sys] /etc/default/nfs-common]'
    end
  end
end
