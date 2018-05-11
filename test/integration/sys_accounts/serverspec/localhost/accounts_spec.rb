require 'spec_helper'

# user with default values
describe user('homer') do
  it { should exist }
  it { should belong_to_group 'homer' }
  # does not work with serverspec
  #its(:uid) { should be >= 1000 }
end

# homedir should not be created
describe file('/home/homer') do
  it { should_not exist }
end

# user with attributes
describe user('lisa') do
  it { should exist }
  it { should belong_to_primary_group 'simpsons' }
  #its(:uid) { should be >= 1000 }
end

# homedir should not be created
describe file('/home/lisa') do
  it { should exist }
end

# user with attributes from data bag
describe user('bart') do
  it { should exist }
  it { should belong_to_primary_group 'simpsons' }
  it { should have_uid 16302 }
  it { should have_login_shell '/bin/mksh' }
end

# homedir should not be created
describe file('/home/bart') do
  it { should exist }
end

# root user:
describe user('root') do
  it { should exist }
  its(:encrypted_password) { should eq '$6$aycaramba$ql7zzi/ASEyEA.MsG5/7I6njGIfXoOn.JJjbToCLfadhYa9axBSJ.bWJiALYy3vA1FnzPx.ycq0uCXqOFrgW6/' }
end
