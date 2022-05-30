require 'spec_helper'

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

describe OpenSSL::X509::Certificate.new(File.read('/tmp/covfefe.pem')) do
  its(:subject) { should eq 'alternativlos.org' }
end
