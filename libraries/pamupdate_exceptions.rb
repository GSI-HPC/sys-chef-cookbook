class PamUpdateError < RuntimeError; end
class ProfileError < PamUpdateError; end
class ConfigError < PamUpdateError; end
