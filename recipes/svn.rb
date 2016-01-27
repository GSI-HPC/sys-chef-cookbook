# -*- coding: utf-8 -*-
#
# Cookbook Name:: sys
# Recipe:: svn
#
# Minimal subversion config
#
# Copyright 2014 GSI Helmholtzzentrum für Schwerionenforschung GmbH <hpc@gsi.de>
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

package 'subversion'

# don't store passwords in plain text:
#  (unless requested by setting the template var 'allow_plaintext_passwords')
template '/etc/subversion/servers' do
  source 'etc_subversion_servers.erb'
end
