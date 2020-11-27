#
# Cookbook Name:: sys
# Recipe:: ssl
#
# Copyright 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
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

defaults = {
  cert: {
    'data_bag'      => 'ssl_certs',
    'data_bag_item' => node['fqdn']
  }
}

node['sys']['ssl']['certs'].each do |attrs|
  cert = defaults[:cert].merge(attrs)
  cert['file'] ||= "/etc/ssl/certs/#{cert['data_bag_item']}.pem"

  begin
    file cert['file'] do
      content data_bag_item(cert['data_bag'], cert['data_bag_item'])['file-content']
      owner 'root'
      group 'root'
      mode  '0644' # this file is public
    end
  rescue Net::HTTPServerException => e
    next
  end
end
