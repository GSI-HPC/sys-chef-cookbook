# try to remove an non-existent alias from a non-existent file
#  should warn but succeed:
sys_mail_alias 'phantomas' do
  action :remove
  aliases_file '/etc/shmalias'
end

sys_mail_alias 'doppelganger' do
  to 'partyevening@example.com'
end

# should not be converged twice
sys_mail_alias 'doppelganger' do
  to 'partyevening@example.com'
end
