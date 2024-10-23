#
# Cookbook:: sys
# Library:: template_header helper
#
# Copyright:: 2019-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Matthias Pausch    <m.pausch@gsi.de>
#  Christopher Huhn   <c.huhn@gsi.de>
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

module Sys
  # module for template_header
  module TemplateHeader
    def chef_product_name
      ChefUtils::Dist::Infra::SHORT
    rescue NameError
      'chef' # fallback if chef too old
    end

    def template_header(comment = '#')
      header = "DO NOT CHANGE THIS FILE MANUALLY!\n\n" \
               "This file is managed by #{chef_product_name}.\n"\
               "Created by #{@cookbook_name}::#{@recipe_name} "\
               "(line #{@recipe_line})"
      header += " from template #{@template_name}" if @template_name
      header.gsub(/^ */, "#{comment} ")
    end
  end
end

Chef::Mixin::Template::TemplateContext.include(Sys::TemplateHeader)
