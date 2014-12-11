#
# Cookbook Name:: sys
# Recipe:: krb5
#
# Copyright 2013, Matthias Pausch
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

unless node.sys.krb5.empty?
  %w(
    heimdal-docs
    heimdal-clients
    libpam-heimdal
    heimdal-kcm
    libsasl2-modules-gssapi-heimdal
  ).each { |p| package p }

  template "/etc/krb5.conf" do
    source "etc_krb5.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :realm => node.default.sys.krb5.realm.upcase,
      :admin_server => node.default.sys.krb5.admin_server,
      :servers => [ node.default.sys.krb5.master, node.default.sys.krb5.slave ],
      :domain => node.domain,
      :wallet_server => begin node.sys.krb5.wallet_server rescue nil end,
      :use_pkinit => begin node.sys.krb5.use_pkinit rescue nil end
    )
  end

  # use a secret or manual distribution of keytabs
  if node.default.sys.krb5.distribution == "secret"

    class Chef::Recipe
      include Sys::Secret
    end

    Chef::Log.info("search for node #{node.sys.krb5.master}")
    kdc_node = search(:node, "fqdn:#{node.sys.krb5.master}")[0]
    if kdc_node
      if node.sys.krb5.has_key?(:"keytab_config")
        node.sys.krb5.keytab_config.each do |kh|
          key = kh["keytab"]
          owner = kh["owner"] || "root"
          group = kh["group"] || "root"
          mode = kh["mode"] || "0600"
          place = kh["place"] || "/etc/#{key}.keytab"
          Chef::Log.info "Put keytab #{key} to place #{place}"
          if kdc_node.krb5.keytabs.has_key?("#{key}_#{node.fqdn}")
            kt = decrypt(kdc_node.krb5.keytabs["#{key}_#{node.fqdn}"])
            # decrypt returns nil if anything goes wrong
            raise "Could not decrypt keytab #{key}" unless kt
            template "#{place}" do
              source "etc_keytab_generic.erb"
              owner owner
              group group
              mode mode
              variables :keytab => kt
              only_if "getent passwd #{owner} && getent group #{group}"
            end
          end
        end
      end
    end
  elsif node.sys.krb5.distribution == "wallet"
    package "wallet-client"
    if node.sys.krb5.has_key?(:"keytab_config")
      if File.exists?("/etc/krb5.keytab")
        node.sys.krb5.keytab_config.each do |kh|
          key = kh["keytab"]
          owner = kh["owner"] || "root"
          group = kh["group"] || "root"
          mode = kh["mode"] || "0600"
          place = kh["place"] || "/etc/#{key}.keytab"
          principal = "#{key}/#{node.fqdn}@#{node.sys.krb5.realm.upcase}"
          Chef::Log.info "Put keytab #{key} to place #{place}"
          bash "deploy #{principal}" do
            cwd "/etc/"
            user "root"
            code <<-EOH
          kinit -t /etc/krb5.keytab host/#{node.fqdn}
          wallet get keytab #{principal} -f #{place}
          kdestroy
          chown #{owner}:#{group} #{place}
          chmod #{mode} #{place}
          EOH
            not_if "ktutil -k #{place} list --keys | grep -q #{principal}"
          end # bash "deploy #{principal}
        end # node.sys.krb5.keytab_config.each
      else # if File.exists?("/etc/krb5.keytab")
        Chef::Log.warn("/etc/krb5.keytab not found, not deploying keytabs.")
      end # if File.exists?("/etc/krb5.keytab")
    else # node.sys.krb5.has_key?(:"keytab_config")
      raise "Distribution set to wallet, but no config found"
    end # node.sys.krb5.has_key?(:"keytab_config")
  end
end
