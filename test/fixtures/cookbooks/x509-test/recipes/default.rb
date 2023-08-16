return unless Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

sys_x509_certificate 'www-linux.gsi.de' do
  bag_item 'www-linux.gsi.de'
  certificate_path '/etc/ssl/certs/www-linux.gsi.de.pem'
  key_path '/etc/ssl/private/www-linux.gsi.de.key'
  include_chain true
end

sys_x509_certificate 'alternativlos' do
  data_bag 'other_certs'
  bag_item 'alternativlos.org'
  certificate_path '/tmp/covfefe.pem'
end

sys_x509_certificate 'nonexistent_bag_item' do
  data_bag 'waldo'
end
