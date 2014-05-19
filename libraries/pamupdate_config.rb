class PamUpdate

  class Config

    attr_accessor :type, :block

    def initialize(type)
      @type = type
      unless %w[ account auth password session session-noninteractive ].include?(type.to_s)
        raise ConfigError, "Found pam-config for unkown type #{type}"
      end
      @block = Hash.new
      @block[:Primary] = Array.new
      @block[:Additional] = Array.new
    end # initialize
  end # Config

end # class PamUpdate
