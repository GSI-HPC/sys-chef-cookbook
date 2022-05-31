return unless Gem::Requirement.new('>= 12.15').satisfied_by?(Gem::Version.new(Chef::VERSION))

x509_certificate 'www-linux.gsi.de'

x509_certificate 'alternativlos' do
  data_bag 'other_certs'
  bag_item 'alternativlos.org'
  certificate_path '/tmp/covfefe.pem'
end

x509_certificate 'nonexistent_bag_item' do
  data_bag 'waldo'
end
