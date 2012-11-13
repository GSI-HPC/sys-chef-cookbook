define :mail_alias, :to => String.new do
  # read the alias file 
  aliases = Hash.new
  (::File.readlines('/etc/aliases')).each do |line|
    next if line =~ /^#/
    account, mail_address = line.split(':')
    aliases[account] = mail_address.lstrip.chop
  end
  # add/change alias
  unless aliases.has_key? params[:name] and aliases[params[:name]] == params[:to] 
    aliases[params[:name]] = params[:to]
    ::File.open('/etc/aliases','w') do |file|
      aliases.each do |account,mail_address|
        file.puts "#{account}: #{mail_address}"
      end
    end
    Chef::Log.info("Postfix aliases #{params[:name]} to #{params[:to]} set.")
    system('newaliases')
  end
end
