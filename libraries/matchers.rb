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

  def set_sys_sdparm(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_sdparm, :set, name)
  end

  def clear_sys_sdparm(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_sdparm, :clear, name)
  end

  def restore_default_sys_sdparm(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_sdparm, :restore_default, name)
  end

  def deploy_sys_wallet(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_wallet, :deploy, name)
  end

  def create_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :create, name)
  end

  def delete_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :delete, name)
  end

  def enable_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :enable, name)
  end

  def disable_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :disable, name)
  end

  def start_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :start, name)
  end

  def stop_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :stop, name)
  end

  def reload_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :reload, name)
  end

  def restart_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :restart, name)
  end

  def mask_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :mask, name)
  end

  def unmask_sys_systemd_unit(name)
    ChefSpec::Matchers::ResourceMatcher.new(:sys_systemd_unit, :unmask, name)
  end
end
