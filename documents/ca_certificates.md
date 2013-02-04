The provider `sys_ca_certificate_file` deploys CA certificate container files.

↪ `resources/ca_certificate_file.rb`  
↪ `providers/ca_certificate_file.rb` 

**Actions**

* `:add` (default) deploy a certificate file from the cookbook.
* `:remove` deletes a certificate file.

**Attributes**

* `name` (name attribute) of the file to be deployed to `/usr/local/share/ca-certificates`.
* `source` is the basename of the file in the cookbook. (Uses the `cookbook_file` resource for deployment)

**Example**

Install a certificate container file to `/usr/local/share/ca-certificates/site.domain`

    sys_ca_certificate_file 'site.domain' do
      source 'site_ca_global_2012.crt'
    end

Remove a certificate file

    sys_ca_certificate_file 'ca-org.domain' do
      action :remove
    end

