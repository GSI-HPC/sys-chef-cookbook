#
# Cookbook:: sys
# Resource:: x509_certificate
#
# Copyright:: 2022-2023 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
  begin
    require 'chef-vault'
  rescue LoadError
    Chef::Log.warn "chef-vault gem not found. sys_x509_certificate cannot be used"
  end

  action_class do
    def certificate_file_content
      cert_item = data_bag_item(new_resource.data_bag, new_resource.bag_item)
      if new_resource.include_chain
        Chef::Log.warn 'Include certificate-chain'
        create_chain(cert_item['file-content']).join("\n")
      else
        cert_item['file-content']
      end
    end

    def key_vault_item
      new_resource.vault_item || new_resource.bag_item
    end

    def key_file_content
      Chef::Log.info "Getting item #{key_vault_item} from vault #{new_resource.chef_vault}"
      key_item = chef_vault_item(new_resource.chef_vault, key_vault_item)
      key_item['file-content']
    end

    def recurse_create_chain(chain, cert)
      # Older openssl-versions don't have the methods for getting the key-identifiers.
      # ski = cert.subject_key_identifier
      # aki = cert.authority_key_identifier
      ski_value = cert.extensions.select {|e| e.oid == "subjectKeyIdentifier" }.first.value
      ski = ski_value.strip.gsub(/\Akeyid:/, '').tr(':', '').downcase
      aki_oid = cert.extensions.select {|e| e.oid == "authorityKeyIdentifier" }.first
      aki = aki_oid ? aki_oid.value.strip.gsub(/\Akeyid:/, '').tr(':', '').downcase : nil
      Chef::Log.warn "ski: #{ski}"
      Chef::Log.warn "aki: #{aki}"

      if ! (aki.nil? || aki == ski)
        chain << cert.to_s.strip
        ca_item = data_bag_item(new_resource.data_bag, aki)
        ca_file = ca_item['file-content']
        recurse_create_chain(chain, OpenSSL::X509::Certificate.new(ca_file))
      end
    end

    def create_chain(cert_file)
      chain = []
      cert = OpenSSL::X509::Certificate.new(cert_file)
      recurse_create_chain(chain, cert)
      return chain
    end
  end

  # unified_mode true

  property :certificate_path,
           String,
           default: lazy { "/etc/ssl/certs/#{bag_item}.pem" }
  property :key_path,
           String,
           default: lazy { "/etc/ssl/private/#{vault_item}.key" }
  property :data_bag,
           String,
           default: 'ssl_certs'
  property :bag_item,
           String,
           name_property: true
  property :chef_vault,
           String,
           default: 'ssl_keys'
  property :vault_item,
           String,
           default: lazy { bag_item }
  property :include_chain,
           [true, false],
           default: false

  action :install do
    package 'ssl-cert'

    begin
      file new_resource.certificate_path do
        content certificate_file_content
        owner 'root'
        group 'root'
        mode '0644'
      end
    rescue Net::HTTPServerException => e
      Chef::Log.warn e.message
    end

    begin
      file new_resource.key_path do
        content key_file_content
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
