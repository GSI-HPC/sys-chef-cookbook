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
      self.profiles = profiles
    end # def initialize

    def add_config(config)
      @configs ||= Array.new
      unless @configs.inject(false) { |acc, v| acc ||= v.type == config.type }
        @configs << config
      end
      self
    end

    def profiles=(values)
      # Throw away anything that has not Default set to yes
      @profiles = values.inject(Array.new) do |ps, p|
        if p.fields["Default"] == "yes"
          ps << p
        else
          ps
        end
      end

      # Sort everything
      @profiles.sort! do |x,y|
        priority = y.fields["Priority"] <=> x.fields["Priority"]
        if priority == 0
          x.fields["Name"] <=> y.fields["Name"]
        else
          priority
        end
      end
    end

    def lines_for_module_and_type(profile, position, type)
      realtype = type.sub(/-noninteractive/, '')
      if position == 0 && profile.fields["#{type.capitalize}-Initial"]
        realtype + "\t\t" + profile.fields["#{type.capitalize}-Initial"]
      else
        realtype + "\t\t" + profile.fields[type.capitalize]
      end
    end # lines_for_module_and_type

    # Collect strings from profiles and put them in arrays in the
    # correct order. This is done for each type.  This function just
    # assembles the necessary strings, jump-addresses are not set.
    def get_configs(type)

      config = PamUpdate::Config.new(type)

      [:Primary, :Additional].each do |block|
        stackposition = 0
        profiles.each do |profile|
          next unless profile.fields["#{type.capitalize}-Type"]
          next unless profile.fields["#{type.capitalize}-Type"] == block.to_s
          config.block[block] << lines_for_module_and_type(profile, stackposition, type)
          stackposition += 1
        end
        realtype = type.sub(/-noninteractive/, '')
        if block.equal?(:Primary)
          if config.block[block].length == 0
            config.block[block] << "#{realtype}\t\t[default=1]\t\tpam_permit.so"
          end
          config.block[block] << "#{realtype}\t\trequisite\t\tpam_deny.so"
          config.block[block] << "#{realtype}\t\trequired\t\tpam_permit.so"
        end
      end
      add_config(config)
    end # def write_profiles

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
      output
    end # create_configs
  end # class Writer
end # class PamUpdate
