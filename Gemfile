source 'http://rubygems.org'

group :development do
  gem 'chefspec', '>= 4.2.0'
  gem 'guard-rspec', require: false
  gem 'libnotify'
  gem 'foodcritic'
  gem 'rubocop', require: false
  gem 'kitchen-vagrant', :git => 'https://github.com/test-kitchen/kitchen-vagrant.git'
  gem 'serverspec'
  gem 'berkshelf'
end

group :vagrant do
  gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant.git', :tag => 'v1.8.1'
  gem 'bundler', :git => 'https://github.com/bundler/bundler', :tag => 'v1.10.6'
  gem 'vagrant-berkshelf'
end

#group :libvirt do
#  gem 'vagrant-libvirt', :git => 'https://github.com/pradels/vagrant-libvirt.git'
#end
