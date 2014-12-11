#
# Cookbook Name:: sys
# Recipe:: pam
#
# Copyright 2013, Bastian Neuburger,  Victor Penso
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
    mode "0600"
    variables :rules => node.sys.pam.access
  end

  unless node.sys.pamd.has_key?('sshd')
    cookbook_file '/etc/pam.d/sshd' do
      source 'etc_pam.d_sshd'
      owner 'root'
      group 'root'
      mode "0644"
      only_if do ::File.exists? '/etc/ssh/sshd_config' end
    end
  end

  unless node.sys.pamd.has_key?('login')
    cookbook_file '/etc/pam.d/login' do
      source 'etc_pam.d_login'
      owner 'root'
      group 'root'
      mode "0644"
    end
  end
end

unless node.sys.pam.limits.empty?
  template '/etc/security/limits.conf' do
    source 'etc_security_limits.conf.erb'
    owner 'root'
    group 'root'
    mode "0644"
    variables :rules => node.sys.pam.limits
  end
end

unless node.sys.pam[:group].empty?
  template '/etc/security/group.conf' do
    source 'etc_security_group.conf.erb'
    owner 'root'
    group 'root'
    mode "0644"
    variables :rules => node.sys.pam.group
  end
end

unless node.sys.pamd.empty?
  node.sys.pamd.each do |name, contents|
    template "/etc/pam.d/#{name}" do
      source 'etc_pam.d_generic.erb'
      owner 'root'
      group 'root'
      mode "0644"
      variables(
        # remove leading spaces, and empty lines
        :rules => contents.gsub(/^ */,'').gsub(/^$\n/,''),
        :name => name
      )
    end
  end
end

unless node.sys.pamupdate.empty?
  begin
    configs = Array.new

    node.sys.pamupdate.each_value do |values|
      configs << PamUpdate::Profile.new(values)
    end

    generator = PamUpdate::Writer.new(configs)

    if ! File.exists?("/etc/krb5.keytab")
      # Remove pam_krb5 from profiles
      generator.remove_profile_byname("Kerberos authentication")
      Chef::Log.warn("/etc/krb5.keytab not present. Not configuring libpam-krb5.")
    end

    %w[ account auth password session session-noninteractive ].each do |type|
      content = generator.send(type)
      unless content.nil?
        template "/etc/pam.d/common-#{type}" do
          source "etc_pam.d_generic.erb"
          owner "root"
          group "root"
          mode "0644"
          variables(
            :rules => content,
            :name => "common-#{type}"
          )
        end
      end
    end
  rescue PamUpdateError => e
    Chef::Log.info(e)
    Chef::Log.info("Not changing /etc/common-*")
  end
end
