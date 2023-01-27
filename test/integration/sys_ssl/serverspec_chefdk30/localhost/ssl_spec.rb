# Cookbook Name:: sys
# Integration tests for recipe sys::ssl
#
# Copyright 2020-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH
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
require 'openssl'

describe file('/etc/ssl/certs/www-linux.gsi.de.pem') do
  it { should exist }
end

describe file('/etc/ssl/private/www-linux.gsi.de.key') do
  it { should exist }
  its(:content) do
    should match(/^-----BEGIN RSA PRIVATE KEY-----\nMIIEcgIBAAK.*/)
  end
end

describe file('/tmp/covfefe.pem') do
  it { should exist }
end

# describe OpenSSL::X509::Certificate.new(File.read('/tmp/covfefe.pem')) do
#   its(:subject) { should eq 'alternativlos.org' }
# end
