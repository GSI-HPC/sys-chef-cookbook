#
# Cookbook Name:: sys
# Recipe:: pam
#
# Copyright 2013-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn    <c.huhn@gsi.de>
#  Dennis Klein        <d.klein@gsi.de>
#  Bastian Neuburger   <b.neuburger@gsi.de>
#  Matthias Pausch     <m.pausch@gsi.de>
#  Victor Penso        <v.penso@gsi.de>
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

if node['sys']['pam']['access'] # ~FC023 Do not break conventions in sys

  #
  # access rules
  #
  template '/etc/security/access.conf' do
    source 'etc_security_access.conf.erb'
    owner 'root'
    group node['sys']['admin_group']
    mode "0640"
    variables(
      rules:   node['sys']['pam']['access'],
      default: node['sys']['pam']['access_default']
    )
  end

  #
  # PAM sshd config
  #
  template '/etc/pam.d/sshd' do
    source 'etc_pam.d_sshd.erb'
    owner 'root'
    group 'root'
    mode "0644"
    only_if do
      ::File.exist?('/etc/ssh/sshd_config')
    end
  end

  #
  # PAM login config
  #
  if node['sys']['pamd']['login'] # ~FC023 Do not break conventions in sys
    template '/etc/pam.d/login' do
      source 'etc_pam.d_login.erb'
      owner 'root'
      group 'root'
      mode "0644"
    end
  end

end

if node['sys']['pam']['namespace'] && node['platform_version'].to_i >= 9 # ~FC023 Do not break conventions in sys
  template '/etc/security/namespace.conf' do
    source 'etc_security_namespace.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end
end

#
# resource limits
#
unless node['sys']['pam']['limits'].empty? # ~FC023 Do not break conventions in sys
  template '/etc/security/limits.conf' do
    source 'etc_security_limits.conf.erb'
    owner 'root'
    group 'root'
    mode "0644"
    variables :rules => node['sys']['pam']['limits']
  end
end

#
# dynamic group membership
#
unless node['sys']['pam']['group'].empty? # ~FC023 Do not break conventions in sys
  template '/etc/security/group.conf' do
    source 'etc_security_group.conf.erb'
    owner 'root'
    group 'root'
    mode "0644"
    variables :rules => node['sys']['pam']['group']
  end
end

unless node['sys']['pamupdate'].empty? # ~FC023 Do not break conventions in sys
  begin
    configs = Array.new

    node['sys']['pamupdate'].each_value do |values|
      configs << PamUpdate::Profile.new(values)
    end

    generator = PamUpdate::Writer.new(configs)

    unless File.exist?("/etc/krb5.keytab")
      # Remove pam_krb5 from profiles
      generator.remove_profile_byname("Kerberos authentication")
      Chef::Log.warn("/etc/krb5.keytab not present. Not configuring libpam-krb5.")
    end

    %w( account auth password session session-noninteractive ).each do |type|
      content = generator.send(type)
      next if content.nil? # ~FC023 Do not break conventions in sys
      template "/etc/pam.d/common-#{type}" do
        source "etc_pam.d_generic.erb"
        owner "root"
        group "root"
        mode "0644"
        variables(
          rules: content
        )
      end
    end
  rescue PamUpdateError => e
    Chef::Log.info(e)
    Chef::Log.info("Not changing /etc/common-*")
  end
end
