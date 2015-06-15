module Sys
  module Helper

    # Detect active systemd instance
    def systemd?
      cmd = Mixlib::ShellOut.new('dpkg -s systemd-sysv')
      cmd.run_command
      cmd.exitstatus == 0
    end
  end
end
