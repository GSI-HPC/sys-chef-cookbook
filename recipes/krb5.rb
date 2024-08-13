#
# Cookbook:: sys
# Recipe:: krb5
#
# Copyright:: 2013-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch     <m.pausch@gsi.de>
#  Christopher Huhn    <c.huhn@gsi.de>
#  Dennis Klein        <d.klein@gsi.de>
#  Bastian Neuburger   <b.neuburger@gsi.de>
#  Thomas Roth         <t.roth@gsi.de>
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

return if node['sys']['krb5'].empty?

%w(
    heimdal-docs
    heimdal-clients
    libpam-heimdal
    libsasl2-modules-gssapi-heimdal
    kstart
).each { |p| package p }

template "/etc/krb5.conf" do
  helpers(Sys::Harry)
  source "etc_krb5.conf_generic.erb"
  mode "0644"
  variables(:sections => node['sys']['krb5']['krb5.conf'])
  only_if { node['sys']['krb5']['krb5.conf'] }
end

# Debian Trixie finally has official wallet packages
# - unfortunately the package naming is different
package debian_version >= 13 ? 'krb5-wallet-client' : 'wallet-client'

sys_wallet "host/#{node['fqdn']}" do
  place "/etc/krb5.keytab"
end
