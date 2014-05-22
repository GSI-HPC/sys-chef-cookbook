class PamUpdate

  class Writer

    alias_method :method_missing_old, :method_missing

    private

    attr_reader :profiles, :configs

    def method_missing(m, *args, &block)
      if %w[ account auth password session session-noninteractive ].include?(m.to_s)
        get_configs(m.to_s)
        create_config(m.to_s)
      else
        method_missing_old(m, *args, &block)
      end
    end

    def initialize(profiles)
      @configs = Array.new
      self.profiles = profiles
    end # def initialize

    def add_config(config)
      unless @configs.inject(false) { |acc, v| acc ||= v.type == config.type }
        @configs << config
      end
      self
    end

    def profiles=(values)
      # Throw away anything that has not Default set to yes
      @profiles = values.inject(Array.new) do |ps, p|
        if p.fields[:Default] == "yes"
          ps << p
        else
          ps
        end
      end

      # Sort everything
      @profiles.sort!
    end

    def lines_for_module_and_type(profile, position, type)
      realtype = type.sub(/-noninteractive/, '')
      if position == 0 && profile.fields[:"#{type.capitalize}-Initial"]
        realtype + "\t\t" + profile.fields[:"#{type.capitalize}-Initial"]
      else
        realtype + "\t\t" + profile.fields[type.capitalize.to_sym]
      end
    end # lines_for_module_and_type

    # Collect strings from profiles and put them in arrays in the
    # correct order. This is done for each type.  This function just
    # assembles the necessary strings, jump-addresses are not set.
    def get_configs(type)

      config = PamUpdate::Config.new(type)
      realtype = String.new
      [:Primary, :Additional].each do |block|
        stackposition = 0
        profiles.each do |profile|
          next unless profile.fields[:"#{type.capitalize}-Type"]
          next unless profile.fields[:"#{type.capitalize}-Type"] == block.to_s
          config.block[block] << lines_for_module_and_type(profile, stackposition, type)
          stackposition += 1
        end
        realtype = type.sub(/-noninteractive/, '')
      end

      if config.block[:Additional].length == 0 &&
          config.block[:Primary].length == 0
        config = nil
      elsif config.block[:Primary].length > 0
        config.block[:Primary] << "#{realtype}\t\trequisite\t\tpam_deny.so"
        config.block[:Primary] << "#{realtype}\t\trequired\t\tpam_permit.so"
      elsif config.block[:Additional].length > 0 &&
          config.block[:Primary].length == 0
          config.block[:Primary] << "#{realtype}\t\t[default=1]\t\tpam_permit.so"
          config.block[:Primary] << "#{realtype}\t\trequisite\t\tpam_deny.so"
          config.block[:Primary] << "#{realtype}\t\trequired\t\tpam_permit.so"
      end

      add_config(config) if config
    end

    # Assume strings to be in the correct order in the arrays. Now fix
    # jump-addresses and create contents of config files as string
    def create_config(type)
      output = String.new
      configs.each do |config|
        next unless config.type == type
        stacksize = config.block[:Primary].length
        config.block[:Primary].each_with_index do |entry, i|
          output += entry.sub(/end/, (stacksize - i - 2).to_s)
          output += "\n"
        end
      end

      configs.each do |config|
        next unless config.type == type
        config.block[:Additional].each do |entry|
          output += "#{entry}\n"
        end
      end

      if ! output.empty?
        output
      else
        nil
      end
    end # create_configs
  end # class Writer
end # class PamUpdate
