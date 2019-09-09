require 'spec_helper'

describe file('/etc/sudoers') do
  it { should exist }
  its(:content) { should match /Defaults\s+mailto="prosecutor@example.com"/ }
end

describe file('/etc/sudoers.d/kitchen') do
  it { should exist }
  its(:content) do
    should include 'User_Alias SMUTJE = vagrant'
    should include 'SMUTJE ALL=(ALL) NOPASSWD: ALL'
  end
end

# should have been cleaned up:
describe file('/etc/sudoers.d/vagrant') do
  it { should_not exist }
end
