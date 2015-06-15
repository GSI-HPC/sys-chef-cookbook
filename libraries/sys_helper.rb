module Sys
  module Helper

    # Detect installed systemd
    def systemd_installed?
      cmd = Mixlib::ShellOut.new('dpkg -s systemd-sysv')
      cmd.run_command
      cmd.exitstatus == 0
    end

    # Detect active systemd instance
    def systemd_active?
      cmd = Mixlib::ShellOut.new('cat /proc/1/comm')
      cmd.run_command
      cmd.stdout.chomp == 'systemd'
    end
  end
end
