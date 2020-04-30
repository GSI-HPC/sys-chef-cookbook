#
# Cookbook Name:: sys
# Serverspec integration tests for sys::apt
#
# Copyright 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
#  Christopher Huhn   <C.Huhn@gsi.de>
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

require 'spec_helper'

describe 'apt config',  if: os[:family] == 'debian' do

  context file('/etc/apt/apt.conf.d/51languages') do
    it { should exist }
    its(:content) do
      should include('Acquire::Languages "none";')
    end
  end

  context file('/etc/apt/preferences.d/sid') do
    it { should exist }
    its(:content) { should include('Package: *') }
    its(:content) { should include('Pin: release l=Debian,n=sid') }
    its(:content) { should include('Pin-Priority: 333') }
  end

  context file('/etc/apt/sources.list.d/sid.list') do
    it { should exist }
    its(:content) do
      should include('deb http://ftp.debian.org/debian sid main')
    end
  end

  context command('apt-cache policy'), if: os[:family] == 'debian' do
    its(:exit_status) { should be_zero }
    its(:stderr) { should be_empty }
    its(:stdout) do
      should include('333 http://ftp.debian.org/debian sid/main')
    end
  end

  context command('apt-key list') do
    its(:exit_status) { should be_zero }
    # stderr of apt-key contains a warning when it is not a terminal
    its(:stdout) do
      should include('2DEC 3301 51BB 9F7D AD8B  0BDC FC32 CEEC A534 A9C6')
    end
    its(:stdout) do
      should match(/uid +\[ unknown\] Felix von Leitner \<felix@fefe\.de\>/)
    end
  end

  context package('nyancat') do
    it { should be_installed }
  end

  context command('dpkg --print-foreign-architectures') do
    its(:exit_status) { should be_zero }
    # TODO: requires installation of Ohai 'debian' plugin
    # its(:stdout) { should be "i386/n" }
    its(:stderr) { should be_empty }
  end
end
