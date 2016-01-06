#
# Cookbook Name:: sys
# Recipe::nscd
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

if ! node['sys']['nscd'].empty?
  package 'nscd'

  template "/etc/nscd.conf" do
    source "etc_nscd.conf.erb"
    user "root"
    group "root"
    mode "0644"
    notifies :restart, "service[nscd]", :delayed
  end

  service "nscd" do
    supports :restart => true
    action [:start, :enable]
    only_if 'test -e /etc/init.d/nscd'
  end
end
