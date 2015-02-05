source 'http://rubygems.org'

group :development do
  gem 'chefspec', '>= 4.2.0'
  gem 'guard-rspec', require: false
  gem 'libnotify'
  gem 'foodcritic'
  gem 'rubocop', require: false
  gem "test-kitchen", :git => "https://github.com/test-kitchen/test-kitchen.git", :tag => "v1.3.1"
  gem "kitchen-vagrant", :git => "https://github.com/test-kitchen/kitchen-vagrant.git"
  gem "serverspec"
  gem "berkshelf"
end

group :vagrant do
  gem "vagrant", :git => "https://github.com/mitchellh/vagrant.git"
end

group :plugins do
  gem "vagrant-libvirt", :git => "https://github.com/pradels/vagrant-libvirt.git"
  gem "vagrant-berkshelf"
end

