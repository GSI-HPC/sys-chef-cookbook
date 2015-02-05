# -*- coding: iso-8859-15 -*-
#
# Cookbook Name:: sys
# Recipe:: cups
#
# Copyright 2013 GSI Helmholtzzentrum für Schwerionenforschung GmbH <hpc@gsi.de>
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

if node['sys']['cups']

  package 'cups-client'

  directory '/etc/cups' do
    mode 0755
  end

  template '/etc/cups/client.conf' do
    source    'etc_generic.erb'
    cookbook  'sys'
    mode      0644
    variables ({
      :content => "ServerName #{node['sys']['cups']['server']}"
    })
    only_if { node['sys']['cups']['server'] }
  end

  #TODO: setup a /etc/cups/lpoptions ?!

end
