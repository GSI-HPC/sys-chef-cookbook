source 'http://rubygems.org'

group :development do
  gem 'rake'
  gem 'rubocop'
  # Foodcritic 13 drops Chef 12 compatibility:
  gem 'foodcritic', '< 13'
  # Newer versions break foodcritic:
  #  https://github.com/Foodcritic/foodcritic/commit/28f6684
  gem 'cucumber-core', '>= 1.3', '< 4.0'
  gem 'berkshelf'

  # take Chef version from environment, fall back to newest version:
  gem 'chef', (ENV['CHEF_VERSION']) ? "~> #{ENV['CHEF_VERSION']}" : "> 1"

  gem 'chefspec', '< 7.3'
  gem 'chefspec-ohai'
  gem 'test-kitchen'

  # gem 'guard-rspec', require: false
  # gem 'libnotify'
  # gem "serverspec"
end

group :travis do
  gem 'kitchen-docker'
end

group :vagrant do
  gem 'vagrant'
  gem 'kitchen-vagrant'
  gem 'vagrant-libvirt'
  gem 'vagrant-berkshelf'
end
