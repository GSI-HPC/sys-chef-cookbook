# Cookbook Name:: sys
# Integration tests for recipe sys::ohai
#
# Copyright 2021-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
#
# Authors:
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

require 'spec_helper'
require 'ohai'

describe file('/var/cache/chef/ohai_plugins') do
  it { should exist }
  it { should be_directory }
end

# describe command('ohai --d /var/cache/chef/ohai_plugins/') do
#   its(:exit_status) { should be_zero }
#   # its(:stdout) { should match(...) }
# end

describe "plugins" do
  before :all do
    @ohai = Ohai::System.new
    Ohai.config[:plugin_path] << '/var/cache/chef/ohai_plugins'
    @ohai.load_plugins
  end

  describe 'platform' do
    subject do
      @ohai.require_plugin('platform')

      @ohai.data
    end

    it { should be_a(Mash) }
    context 'on debian', :if => os[:family] == 'debian' do
      it { should include(platform: 'debian') }
    end
  end

  describe 'debian' do
    subject do
      @ohai.require_plugin('debian')

      @ohai.data['debian']
    end

    it { should be_a(Mash) }
    it do
      # the base-files package should always be installed:
      should include(packages: a_hash_including(
                       'base-files' => {
                         version:  anything,
                         status:  'install ok installed',
                         arch:    'amd64',
                         src_pkg: 'base-files'
                       }
                     ))
    end
  end

  describe 'ssh fingerprints' do
    subject do
      @ohai.require_plugin('keys/ssh/fingerprints')

      @ohai.data['keys']['ssh']['fingerprints']
    end

    it { should be_a(Mash) }
    it do
      # TODO: don't hard-code rsa here
      #  'anything'  or match(...) don't seem to work for a hash key though
      should include(rsa: {
                       md5: match(/^[0-9a-f]{2}(:[0-9a-f]{2}){15}$/i),
                       sha256: match(%r{^[A-Za-z0-9/+]+$})
                     })
    end
  end
end
