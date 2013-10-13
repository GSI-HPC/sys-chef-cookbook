#!/usr/bin/ruby
# -*- coding: iso-8859-15 -*-
#
# plugin to gather dpkg-related information
#
# $Id$
#
# Copyright 2013 GSI Helmholtzzentrum f�r Schwerionenforschung GmbH <hpc@gsi.de>
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

require 'json'

# useless unless we are on a debian derivative
if platform_family.eql?('debian')

  # read a list of installed packages:
  provides 'debian'

  # dpkg-query can be told to produce arbitrary output
  #  inspired by https://github.com/demonccc/chef-repo/blob/master/plugins/ohai/linux/dpkg.rb
  #  but instead of eval'ing the output, we produce JSON and parse it, which is much more secure
  #  as it prevents us from running arbitrary Ruby code via a forged dpkg-query ...
  debian Mash.new
  debian['packages'] = JSON.parse('{' + `dpkg-query -W -f='"${Package}": {"version":"${Version}", "status":"${Status}"}\n'`.split("\n").join(',') + '}')
  
  # figure out the debian architecture (not neccessarily equal to node.kernel.machine!)
  debian["architecture"]          = `dpkg --print-architecture`.chomp
  # list of enabled multiarch architectures (eg. i386 on amd64):
  debian["foreign_architectures"] = `dpkg  --print-foreign-architectures`.split("\n")

  # this is already provided by the LSB plugin:
  debian["codename"]     = `lsb_release -cs`.chomp
end
