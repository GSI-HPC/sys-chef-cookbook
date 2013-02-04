Display a static login message by creating `/etc/motd`.

↪ `attributes/banner.rb`  
↪ `recipes/banner.rb`  
↪ `templates/*/etc_motd.erb`  
↪ `templates/*/etc_profile.d_info.sh.erb`  
↪ `tests/roles/sys_banner_test.rb`  

**Attributes**

All attributes in `node.sys.banner`:

* `message` (required) text normally describing the purpose of the node.
* `header` (optional) text printed in front of the banner message.
* `footer` (optional) text printed after the banner message.
* `info` (default `true`) deploys a script in `/etc/profile.d/info.sh` displaying system statistics and information about the Chef deployment.

**Example**

A generic role for the infrastructure may contain global header and footer content.

    [...SNIP]
    default_attributes(
      "sys" => {
        "banner" => {
          "header" => "Welcome to Linux...",
          "footer" => "Report problems by sending mails to devops@localhost"
        }
        [...SNIP...]
      }
      [...SNIP...]
    )

For specific roles/nodes the message describes the hosts purpose.

    [...SNIP...]
    "sys" => {
      "banner" => {
        "message" => "Interactive login pool to huge compute cluster"
      }
      [...SNIP...]

