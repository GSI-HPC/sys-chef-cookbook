source 'http://rubygems.org'

group :development do
  gem 'rake'
  gem 'rubocop'
  # Foodcritic 13 drops Chef 12 compatibility:
  gem 'foodcritic', '< 13'
  gem 'berkshelf'

  # take Chef version from environment, fall back to newest version:
  gem 'chef', (ENV['CHEF_VERSION']) ? "~> #{ENV['CHEF_VERSION']}" : "> 1"

  gem 'chefspec'
  gem 'chefspec-ohai'
  gem 'test-kitchen'

  # gem 'guard-rspec', require: false
  # gem 'libnotify'
  # gem "serverspec"
end

group :travis do
  gem 'kitchen-docker'
end

# group :vagrant do
#   gem "vagrant", :git => "https://github.com/mitchellh/vagrant.git",
#       :tag => 'v1.7.4'
#   gem "kitchen-vagrant",
#       :git => "https://github.com/test-kitchen/kitchen-vagrant.git"
#   gem "vagrant-libvirt",
#       :git => "https://github.com/pradels/vagrant-libvirt.git"
#   gem "vagrant-berkshelf"
# end
