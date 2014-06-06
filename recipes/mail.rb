#
# Cookbook Name:: sys
# Recipe:: mail
#
# Copyright 2012, Victor Penso
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

relay = node.sys.mail.relay

unless relay.empty?

  package 'postfix'
  service 'postfix' do
    supports :reload => true
  end

  file '/etc/mailname' do
    content "#{node.fqdn}\n"
  end

  update_canonical = "Update Postfix canonicals"
  execute update_canonical do
    action :nothing
    command "postmap /etc/postfix/canonical"
    notifies :reload, "service[postfix]"
  end

  template '/etc/postfix/canonical' do
    source 'etc_postfix_canonical.erb'
    mode "600"
    notifies :run, "execute[#{update_canonical}]", :immediate
  end

  template '/etc/postfix/main.cf' do
    source 'etc_postfix_main.cf.erb'
    mode "0644"
    variables({
        :relay           => relay, 
        :mynetworks      => node[:sys][:mail][:mynetworks],
        :inet_interfaces => node[:sys][:mail][:inet_interfaces],
      })
    notifies :reload, "service[postfix]"
  end

  node.sys.mail.aliases.each do |account,mail_address|
    sys_mail_alias account do
      to mail_address
    end
  end

  execute "Rebuild missing /etc/postfix/canonical" do
    not_if do
      ::File.exists? '/etc/postfix/canonical'
    end
    notifies :run, "execute[#{update_canonical}]", :immediate
  end

end
