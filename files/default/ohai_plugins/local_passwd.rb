provides 'etc', 'current_user'

require 'etc'

unless etc
  etc Mash.new

  etc[:passwd] = Mash.new
  etc[:group] = Mash.new

  File.readlines("/etc/passwd").each do |line|
    splitline = line.chomp.split(":")
    etc[:passwd][splitline[0]] = Mash.new(:dir => splitline[5], :uid => splitline[2].to_i, :gid => splitline[3].to_i, :shell => splitline[6], :gecos => splitline[4])
  end

  File.readlines("/etc/group").each do |line|
    splitline = line.chomp.split(":")
    g_members = []
    splitline[3].split(",").each{ |mem| g_members << mem }
    etc[:group][splitline[0]] = Mash.new(:gid => splitline[2].to_i, :members => g_members)
  end

end

unless current_user
  current_user Etc.getlogin
end
