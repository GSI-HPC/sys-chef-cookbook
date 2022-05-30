#
# Cookbook:: sys
# Resource:: x509_certificate
#
# Copyright:: 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch (m.pausch@gsi.de)
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
# This code is an adjustment of https://github.com/sous-chefs/firewall
#

if Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

  provides :x509_certificate, os: 'linux'
  # unified_mode true

  property :description,
           String,
           name_property: true
  property :certificate_path,
           String,
           default: lazy { "/etc/ssl/certs/#{node['fqdn']}.pem" }
  property :key_path,
           String,
           default: lazy { "/etc/ssl/private/#{node['fqdn']}.pem" }
  property :data_bag,
           String,
           default: 'ssl_certs'
  property :data_bag_item,
           String,
           default: lazy { node['fqdn'] }
  property :chef_vault,
           String,
           default: 'ssl_keys'
  property :chef_vault_item,
           String,
           default: lazy { node['fqdn'] }

  action :install do
    package 'ssl-cert'

    begin
      file new_resource.certificate_path do
        content data_bag_item(new_resource.data_bag, new_resource.data_bag_item)['file-content']
        owner 'root'
        group 'root'
        mode '0644'
      end
    rescue Net::HTTPServerException => e
      Chef::Log.warn e.message
    end

    begin
      file new_resource.key_path do
        content chef_vault_item(new_resource.chef_vault, new_resource.chef_vault_item)['file-content']
        owner 'root'
        group 'ssl-cert'
        mode '0640'
        sensitive true
      end
    rescue Net::HTTPServerException, ChefVault::Exceptions => e
      Chef::Log.warn e.message
    end
  end
end
