require 'chefspec'
require 'chefspec/server'

class ChefSpec::Runner
  alias_method :server_initialize, :initialize

  def initialize(options = {}, &block)
    case options[:mode]
    when :solo
      old_initialize(options, &block)
    when :server
      server_initialize(options, &block)
    else
      old_initialize(options, &block)
    end
  end
end


#ChefSpec::Coverage.start!

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks (default: [inferred from
  # the location of the calling spec file])
  #config.cookbook_path = '/var/cookbooks'

  # Specify the path for Chef Solo to find roles (default: [ascending search])
  #config.role_path = '/var/roles'

  # Specify the Chef log_level (default: :warn)
  #config.log_level = :debug

  # Specify the path to a local JSON file with Ohai data (default: nil)
  #config.path = 'ohai.json'

  # Specify the operating platform to mock Ohai data from (default: nil)
  config.platform = 'debian'

  # Specify the operating version to mock Ohai data from (default: nil)
  config.version = '7.0'
end
