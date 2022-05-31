#
# Cookbook:: sys
# Library:: Helpers::X509
#
# Copyright:: 2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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

module Sys
  module Helpers
    module X509
      def certificate_file_content(new_resource)
        cert_item = data_bag_item(new_resource.data_bag, new_resource.bag_item)
        cert_item['file-content']
      end

      def key_vault_item(new_resource)
        new_resource.vault_item || new_resource.bag_item
      end

      def key_file_content(new_resource)
        key_item = chef_vault_item(new_resource.chef_vault,
                                   key_vault_item(new_resource))
        key_item['file-content']
      end
    end
  end
end
