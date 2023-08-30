require 'spec_helper'

if os[:release].to_i >= 10
  describe file('/etc/ssl/certs/www-linux.gsi.de_chain.pem') do
    it { should exist }
    its(:content) do
      should match(/^lnwgvLxGmf4+6iWA+dvG3PHirgCHyWmVTOwy7+ikhEdtd9q4\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIFrDCCBJSgAwIBAgIHG2O60B4sPTANBgkqhkiG9w0BAQsFADCBlTELMAkGA1UEGqK1chk5$/)
      should match(/^LXUV2EoY6hbvVTQiGhONBg==\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIFEjCCA\/qgAwIBAgIJAOML1fivJdmBMA0GCSqGSIb3DQEBCwUAMIGCMQswCQYD$/)
      should match(/^qK1chk5\n-----END CERTIFICATE-----\z/)
    end
  end

  describe file('/etc/ssl/certs/www-linux.gsi.de_no_chain.pem') do
    it { should exist }
    its(:content) do
      should_not match(/^GqK1chk5$/)
      should match(/^lnwgvLxGmf4+6iWA+dvG3PHirgCHyWmVTOwy7+ikhEdtd9q4\n-----END CERTIFICATE-----\z/)
    end
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
