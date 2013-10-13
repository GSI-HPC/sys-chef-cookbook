# -*- coding: iso-8859-15 -*-
#
# Cookbook Name:: sys
# Recipe::        cfengine
# Description::   set up the cfengine client (v2)
#
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

if node[:sys][:cfengine]

  package 'cfengine2'

  cookbook_file '/etc/cfengine/update.conf' do
    source 'etc_cfengine_update.conf'
    # do nothing if this file is already in place:
    action :create_if_missing
  end

  service 'cfengine2'

end
