if defined?(ChefSpec)
  def add_sys_apt_key(key)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_key, :add, key)
  end

  def remove_sys_apt_key(key)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_key, :remove, key)
  end

  def add_sys_apt_repository(repo)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_repository, :add, repo)
  end

  def remove_sys_apt_repository(repo)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_repository, :remove, repo)
  end

  def set_sys_apt_preference(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_preference, :set, name)
  end

  def remove_sys_apt_preference(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_preference, :remove, name)
  end

  def set_sys_apt_conf(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_conf, :set, name)
  end

  def remove_sys_apt_conf(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_apt_conf, :remove, name)
  end

  def add_sys_mail_alias(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_mail_alias, :add, name)
  end

  def remove_sys_mail_alias(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_mail_alias, :remove, name)
  end
end
