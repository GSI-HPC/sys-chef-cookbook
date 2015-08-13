Ohai.plugin(:LocalPasswd) do
  provides 'etc', 'etc/passwd', 'etc/group', 'current_user'

  collect_data(:default) do
    require 'etc'

    etc Mash.new unless etc
    current_user Etc.getlogin unless current_user

    etc['passwd'] = Mash.new
    etc['group'] = Mash.new

    File.readlines('/etc/passwd').each do |line|
      splitline = line.chomp.split(':')
      etc['passwd'][splitline[0]] = Mash.new(
        'dir' => splitline[5],
        'uid' => splitline[2].to_i,
        'gid' => splitline[3].to_i,
        'shell' => splitline[6],
        'gecos' => splitline[4]
      )
    end

    File.readlines('/etc/group').each do |line|
      splitline = line.chomp.split(':')
      g_members = []
      String(splitline[3]).split(',').each do |mem|
        g_members << mem
      end
      etc['group'][splitline[0]] = Mash.new(
        'gid' => splitline[2].to_i,
        'members' => g_members
      )
    end
  end
end
