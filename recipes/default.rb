#
# Cookbook Name:: sys
# Recipe:: default
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

# the order of recipes matters!
%w(
   apt directory serial boot control accounts sudo
   time network nsswitch nis hosts resolv mail
   fuse pam ssh banner tmp autofs sdparm
).each do |recipe|
  include_recipe "sys::#{recipe}"
end
