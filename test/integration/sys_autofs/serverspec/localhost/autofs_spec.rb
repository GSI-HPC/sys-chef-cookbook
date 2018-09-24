require 'spec_helper'

describe service('autofs') do
  xit { should be_enabled } # fails on travis, systemd not detected by specinfra on stretch?
  it { should be_running }
end

# bind-mounted /tmp
describe file('/test/tempo/my_testfile') do
  let(:banner) { 'Created by sys::autofs integration test' }

  before do
    # write file to /tmp
    File.write('/tmp/my_testfile', banner)
  end

  it { should exist }
  its(:content) { should include(banner) }
end
