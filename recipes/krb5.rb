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

if node.sys.krb5
  %w(
    heimdal-clients
    libpam-heimdal
    heimdal-kcm
    heimdal-docs
    libsasl2-modules-gssapi-heimdal
  ).each { |p| package p }

  template "/etc/krb5.conf" do
    source "etc_krb5.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :realm => node.sys.krb5.realm.upcase,
      :admin_server => node.sys.krb5.admin_server,
      :servers => [ node.sys.krb5.master, node.sys.krb5.slave ],
      :domain => node.domain
    )
  end

  # use a secret or manual distribution of keytabs
  if node.sys.krb5.distribution == "secret"
    Chef::Log.info("search for node #{node.sys.krb5.master}")

    class Chef::Recipe
      include Sys::Secret
    end

    kdc_node = search(:node, "fqdn:#{node.sys.krb5.master}")[0]
    if kdc_node
      if node.sys.krb5.keytab_config
        node.sys.krb5.keytab_config.each do |kh|
          key = kh["keytab"]
          owner = kh["owner"] || "root"
          group = kh["group"] || "root"
          mode = kh["mode"] || "0600"
          place = kh["place"] || "/etc/#{key}.keytab"
          if kdc_node.krb5.keytabs.has_key?("#{key}_#{node.fqdn}")
            kt = decrypt(kdc_node.krb5.keytabs["#{key}_#{node.fqdn}"])
            template "#{place}" do
              source "etc_keytab_generic.erb"
              owner owner
              group group
              mode mode
              variables :keytab => kt
            end
          end
        end
      end
    end
  end
end
