#
# Cookbook Name:: sys
# Recipe:: ssl
#
# Copyright 2020-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Andre Kerkhoff     <A.Kerkhoff@gsi.de>
#  Christopher Huhn   <C.Huhn@gsi.de>
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
#
#

return unless node['sys']['ssl']

package 'ssl-cert'

defaults = {
  cert: {
    'data_bag'      => 'ssl_certs',
    'data_bag_item' => node['fqdn'],
    'include_chain' => false,
    'key_vault'     => 'ssl_keys'
  }
}
use_resource = Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

node['sys']['ssl']['certs'].each do |attrs|
  cert = defaults[:cert].merge(attrs)
  cert['file'] ||= "/etc/ssl/certs/#{cert['data_bag_item']}.pem"
  cert['key_file'] ||= "/etc/ssl/private/#{cert['data_bag_item']}.key"

  if use_resource

    sys_x509_certificate cert['data_bag_item'] do
      certificate_path cert['file']
      key_path cert['key_file']
      data_bag cert['data_bag']
      include_chain cert['include_chain']
      chef_vault cert['key_vault']
    end

  else

    begin
      file cert['file'] do
        content data_bag_item(cert['data_bag'], cert['data_bag_item'])['file-content']
        owner 'root'
        group 'root'
        mode  '0644' # this file is public
      end
    rescue Net::HTTPServerException
      next
    end

    begin
      file cert['key_file'] do
        content chef_vault_item(cert['key_vault'], cert['data_bag_item'])['file-content']
        owner 'root'
        group 'ssl-cert'
        mode  '0640' # this file is only readable for the ssl-cert group
        sensitive true
      end
    rescue Net::HTTPServerException, ChefVault::Exceptions => e
      Chef::Log.warn "Could not retrieve SSL key for #{cert['data_bag_item']}: #{e}"
    end

  end
end
