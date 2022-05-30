return unless Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

x509_certificate 'www-linux' do
  data_bag_item 'www-linux.gsi.de'
  certificate_path '/etc/ssl/certs/www-linux.gsi.de.pem'
  key_path '/etc/ssl/private/www-linux.gsi.de.key'
end

x509_certificate 'alternativlos.org' do
  data_bag 'other_certs'
  data_bag_item 'alternativlos.org'
  certificate_path '/tmp/covfefe.pem'
end

x509_certificate 'nonexistent data bag' do
  data_bag 'waldo'
end
