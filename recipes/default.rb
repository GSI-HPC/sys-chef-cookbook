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

# the order of including matters!
include_recipe 'sys::apt'
include_recipe 'sys::serial'
include_recipe 'sys::boot'
include_recipe 'sys::cgroups'
include_recipe 'sys::control'
include_recipe 'sys::sudo'
include_recipe 'sys::time'
include_recipe 'sys::network'
include_recipe 'sys::nsswitch'
include_recipe 'sys::nis'
include_recipe 'sys::hosts'
include_recipe 'sys::resolv'
include_recipe 'sys::mail'
include_recipe 'sys::fuse'
include_recipe 'sys::pam'
include_recipe 'sys::ssh'
include_recipe 'sys::banner'
include_recipe 'sys::tmp'
