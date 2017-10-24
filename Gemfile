source 'http://rubygems.org'

group :development do
  gem 'rake'
  gem 'rubocop'
  gem 'foodcritic'
  gem 'berkshelf'
  gem 'chef', "~> #{ENV['CHEF_VERSION']}"
  gem 'chefspec'
  gem 'test-kitchen'
  gem 'kitchen-docker'
  # gem 'guard-rspec', require: false
  # gem 'libnotify'
  # gem "kitchen-vagrant",
  #    :git => "https://github.com/test-kitchen/kitchen-vagrant.git"
  # gem "serverspec"
end

platforms :ruby_21 do
  gem 'ffi-yajl', '~> 2.2'
end

# group :vagrant do
#   gem "vagrant", :git => "https://github.com/mitchellh/vagrant.git",
#       :tag => 'v1.7.4'
# end

# group :plugins do
#   gem "vagrant-libvirt",
#       :git => "https://github.com/pradels/vagrant-libvirt.git"
#   gem "vagrant-berkshelf"
# end
