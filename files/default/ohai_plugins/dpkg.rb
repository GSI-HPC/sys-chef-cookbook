#!/usr/bin/ruby
#
# Cookbook Name:: sys
# File:: files/default/ohai_plugins/dpkg.rb
#
# Copyright 2013-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn    <c.huhn@gsi.de>
#  Bastian Neuburger   <b.neuburger@gsi.de>
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
# plugin to gather dpkg-related information
#

require 'json'
require 'mixlib/shellout'

# New 'header' for Ohai plugins
Ohai.plugin(:Dpkg) do
  # Are there any attributes this plugin depends on?
  depends 'platform_family'
  depends 'platform_version'

  # Which attribute name space will this plugin take care of?
  provides 'debian'

  # read a list of installed packages:
  # dpkg-query can be told to produce arbitrary output
  #  inspired by https://github.com/demonccc/chef-repo/blob/master/plugins/ohai/linux/dpkg.rb
  #  but instead of eval'ing the output, we produce JSON and parse it,
  #  which is much more secure as it prevents us from running arbitrary
  #  Ruby code via a forged dpkg-query ...
  def package_data
    dpkg_query = 'dpkg-query -W -f=\'"${Package}": {' \
                 '"version": "${Version}",' \
                 '"status":  "${Status}",' \
                 '"arch":    "${Architecture}",' \
                 '"src_pkg": "${source:Package}"' \
                 '}\n\''
    dpkg_query_so = shell_out(dpkg_query)

    if dpkg_query_so.error?
      Ohai::Log.error "dpkg-query failed: #{dpkg_query_so}"
      return
    end

    JSON.parse("{#{dpkg_query_so.stdout.split("\n").join(',')}}")
  end

  # Start populating the attribute name space this plugin is responsible for.
  collect_data(:linux) do
    # Only within the collect_data methods you can access the
    # attributes you declared with 'depends' above
    unless platform_family.eql?('debian')
      # Print a warning that this plugin is probably not usefule if
      # platform_family != debian
      Ohai::Log.info "Not a debian derivative, #{__FILE__} only collects " \
                     "data for nodes with platform_family.eq? 'debian'."
      return
    end

    debian Mash.new

    debian['packages'] = package_data

    # figure out the debian architecture
    #  (differs from  node['kernel']['machine']!)
    debian["architecture"] = shell_out('dpkg --print-architecture').stdout.chomp

    # list of enabled multiarch architectures (eg. i386 on amd64):
    #  no multiarch before Wheezy
    if platform_version.to_i > 6 || platform_version =~ %r{/sid$}
      debian["foreign_architectures"] =
        shell_out('dpkg  --print-foreign-architectures').split("\n")
    end
  end
end
