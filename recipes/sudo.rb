#
# Cookbook Name:: sys
# Recipe:: sudo
#
# Copyright 2012-2021, GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

if node['sys']['sudo_ldap'].empty? &&
   # check wether node['sys']['sudo'] contains anything:
   !node['sys']['sudo'].empty?

    package 'sudo'

    # Prevent "undefined method `[]' for nil:NilClass":
    if node['sys']['sudo']['config']
      mailto   = node['sys']['sudo']['config']['mailto']
      mailfrom = node['sys']['sudo']['config']['mailfrom']
      mailsub  = node['sys']['sudo']['config']['mailsub']
      cleanup  = node['sys']['sudo']['config']['cleanup']
    end

    # make sure to keep the right permissions and ownership
    # on this file.
    template '/etc/sudoers' do
      source 'etc_sudoers.erb'
      owner 'root'
      group 'root'
      mode "0440"
      variables(
        mailto:   mailto,
        mailfrom: mailfrom,
        mailsub:  mailsub
      )
    end

    # system specific configurations should be applied by
    # individual files in this directory
    directory '/etc/sudoers.d' do
      owner 'root'
      group 'root'
      mode "0755"
    end

    # delete sudo rules not managed by sys
    #  if node['sys']['sudo']['cleanup'] == true
    Dir.glob('/etc/sudoers.d/*').each do |f|
      file f do
        action :delete
        only_if { cleanup }
        # keep the README:
        not_if { f == '/etc/sudoers.d/README' }
        # keep files with a correspoming attribute:
        not_if { node['sys']['sudo'].key?(File.basename(f)) }
      end
    end

    # filter out config branch from attribute tree:
    node['sys']['sudo'].reject do |key|
      key.to_s == 'config'
    end.each_pair do |name, options|
      # skip empty config:
      next unless options

      sys_sudo name do
        defaults options['defaults']
        users    options['users']
        hosts    options['hosts']
        commands options['commands']
        rules    options['rules']
      end
    end
elsif ! node['sys']['sudo_ldap'].empty?
  package 'sudo-ldap'

  sys_wallet "sudoers/#{node['fqdn']}" do
    place "/etc/sudoers.keytab"
    owner "root"
    group "root"
    mode "0600"
  end

  template '/etc/sudoers' do
    source 'etc_sudoers_ldap.erb'
    owner 'root'
    group 'root'
    mode '0400'
  end

  template "/etc/sudo-ldap.conf" do
    source 'etc_sudo-ldap.conf.erb'
    owner 'root'
    group 'root'
    mode  '0400'
    variables(
      servers: Array(node['sys']['sudo_ldap']['servers'])
    )
  end

  # TODO: Start krb5cc for sudoers
  # TODO: configure nsswitch for sudoers
end
