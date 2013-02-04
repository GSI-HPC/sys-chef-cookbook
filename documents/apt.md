
Configures the APT package management on Debian.

↪ `attributes/apt.rb`  
↪ `recipes/apt.rb`  
↪ `resources/apt_preferences.rb`  
↪ `resources/apt_conf.rb`  
↪ `resources/apt_repository.rb`  
↪ `providers/apt_preferences.rb`  
↪ `providers/apt_conf.rb`  
↪ `providers/apt_repository.rb`  
↪ `templates/*/etc_apt_preferences.d_generic.erb`  
↪ `templates/*/etc_apt_sources.list.d_generic.erb`  
↪ `tests/roles/sys_apt_test.rb`  

### Main Repository

Configure the main source repository in `/etc/apt/sources.list` using the attribute `node.sys.apt.sources`, for example:

    "sys" => {
      "apt" => {
        "sources" => "
          deb     http://debian.site.domain/debian wheezy main contrib
          deb-src http://debian.site.domain/debian wheezy main contrib
        ",
        [...SNIP...]
      }
    }

### Configuration

Set APT configurations with individual file in the `/etc/apt/apt.conf.d/` directroy using the **`sys_apt_conf`** resource.  

**Actions**

* `set` (default) creates a new APT configuration file.
* `remove` deletes an APT configuration file.

**Attributes**

* `name` (name attribute) is the filename used for the configuration.
* `config` (required) to be written into the configuration file.

**Examples**

Configure a couple APT specifics:
     
    sys_apt_conf "10periodic" do
      config(
        "APT::Periodic::Enable" => 1,
        "APT::Periodic::Update-Package-Lists" => 1,
        "APT::Periodic::Unattended-Upgrade" => 1,
        "APT::Periodic::Download-Upgradeable-Packages" => 1,
        "APT::Periodic::AutocleanInterval" => 7
      )
    end

    sys_apt_conf "50pdiffs" do
      config( "Acquire::PDiffs" => false )
    end

Alternatively use attributes in the `node.sys.apt.config`, e.g.:

    "sys" => {
      [...SNIP...]
      "apt" => {
        "config" => {
          "51retries" => {
            "Acquire::Retries" => 0
          },
          "60unattended-upgrade" => {
            "Unattended-Upgrade::Automatic-Reboot" => false,
            "Unattended-Upgrade::Remove-Unused-Dependencies" => true;
            "Unattended-Upgrade::Mail" => "root",
            "Unattended-Upgrade::MailOnlyOnError" => true
          }
        }
        [...SNIP...]
      }
    } 


### Preferences

Set APT preferences with individual files in the `/etc/apt/preferences.d/` directory using the **`sys_apt_preference`** resource (refer to the `apt_preferences` manual).

**Actions**

* `set` (default) creates a new APT preferences configuration file.
* `remove` deletes an APT preferences configuration file.

**Attributes**

* `name` (name attribute) is the filename used for the configuration.
* `package` (defaults to any, as specified by asterisk) list.   
* `pin` (required) specifies the release.
* `priority` (required) specifies the priority level.

**Examples**

Defines precedents for the testing packages over unstable.

    sys_apt_preference "testing" do
      pin "release o=Debian,a=testing"
      priority 900
    end
 
    sys_apt_preference "unstable" do
      pin "release o=Debian,a=unstable"
      priority 800
    end

    sys_apt_preference "site-testing" do
      action :remove
    end

Alternatively use attributes in the `node.sys.apt.preferences` to configure, e.g.:

    [...SNIP...]
    "sys" => {
      "apt" => {
        "preferences" => {
          "testing" => {
            "pin" => "release o=Debian,a=testing",
            "priority" => 400
          },
          "unstable" => {
            "pin" => "release o=Debian,a=unstable",
            "priority" => 200
          },
          "site-testing" => {
            "package" => "foo",
            "pin" => "o=site,a=testing",
            "priority" => 900
          }
        }
      }
      [...SNIP...]
    }

Leaving a key with an empty hash a value in the `node.sys.apt.preferences` will remove the corresponding configuration file if present.

