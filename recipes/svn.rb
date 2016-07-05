# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: svn
#
# Minimal subversion config
#
# Copyright 2014-2016 GSI Helmholtzzentrum für Schwerionenforschung GmbH <hpc@gsi.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# All rights reserved - Do Not Redistribute
#

if node['sys']['svn']
  package 'subversion'

  # we need this ugly attribute checking to avoid NoMethodError:
  #  undefined method `[]' for nil:NilClass

  proxy = { }

  if node['sys']['svn']['proxy']
    proxy = {
      # use subversion specific proxy settings
      host: node['sys']['svn']['proxy']['host'],
      port: node['sys']['svn']['proxy']['port'],
      # apparently incompatible with $NO_PROXY:
      exceptions:  node['sys']['svn']['proxy']['exceptions']
    }
  end

  if node['sys']['http_proxy']
    # fall back to the generic http_proxy attributes
    proxy[:host] ||= node['sys']['http_proxy']['host']
    proxy[:port] ||= node['sys']['http_proxy']['port']
  end

  template '/etc/subversion/servers' do
    source 'etc_subversion_servers.erb'
    variables(
      # don't store passwords in plain text:
      #  (unless requested by setting 'store_plaintext_passwords')
      store_plaintext_passwords:
        node['sys']['svn']['store_plaintext_passwords'],
      proxy: proxy
    )
  end
end
