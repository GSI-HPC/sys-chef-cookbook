require 'spec_helper'

if os[:release].to_i >= 10
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

  describe x509_certificate('/tmp/covfefe.pem') do
    its('subject') { should eq 'CN = alternativlos.org' }
  end
end
