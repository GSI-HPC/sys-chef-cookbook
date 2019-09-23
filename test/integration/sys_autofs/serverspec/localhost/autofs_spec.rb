require 'spec_helper'

describe service('autofs') do
  # this check does not work on Travis for Debian Stretch
  xit { should be_enabled }
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
