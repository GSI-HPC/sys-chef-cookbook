#
# Cookbook Name:: sys
# Recipe:: modules
#
# Copyright 2014-2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matteo Dessalvi   <m.dessalvi@gsi.de>
#  Matthias Pausch   <m.pausch@gsi.de>
#  Victor Penso      <v.penso@gsi.de>
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

return if node['sys']['modules'].empty?

node['sys']['modules'].each do |m|
  sys_module m
end
