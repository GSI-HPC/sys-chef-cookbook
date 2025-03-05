#
# Cookbook:: sys
# Resource:: sys_apt_key
#
# Copyright:: 2013-2025 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <c.huhn@gsi.de>
#  Dennis Klein       <d.klein@gsi.de>
#  Matthias Pausch    <m.pausch@gsi.de>
#  Victor Penso       <v.penso@gsi.de>
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

# input property of execute resource appeared in Chef 16.2
if Gem::Requirement.new('>= 16.2')
     .satisfied_by?(Gem::Version.new(Chef::VERSION))

  default_action :add
  property :key, String, required: true
  property :keyring, String,  name_property: true,
           coerce: proc { |name| name.gsub(/[\s:]+/, '-').downcase }

  action :add do
    directory '/etc/apt/keyrings' do
      mode 0o755
    end

    execute 'import key into keyring' do
      command "gpg --no-default-keyring --keyring /etc/apt/keyrings/#{new_resource.keyring}.gpg --import"
      input new_resource.key
    end
  end

  action :remove do
    # this assumes that the keyring contains exactly one key:
    file "/etc/apt/keyrings/#{new_resource.keyring}.gpg" do
      action :delete
    end
  end

else
  # old school custom resource
  actions :add, :remove
  default_action :add
  attribute :key, :kind_of => String, :name_attribute => true
end
