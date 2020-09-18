Configure Domain Name Service (DNS) resolution.

↪ `attributes/resolv.rb`  
↪ `recipes/resolv.rb`  
↪ `templates/*/etc_resolv.conf.erb`  

**Attributes**

All attributes in `node.sys.resolv`:


| `servers` | Array | required | list a DNS server IPs |
| `domain` | String | optional | local domain name |
| `search` | Array or String | optional | list for host-name lookup |
| `options` | Array | optional | list of options |
| `force` | Boolean, default: false | optional |  make sys::resolv overwrite `/etc/resolv.conf` even though it is a link (eg. managed by resolvconf) |

If both `search` and `domain` are specified the latter will be ignored as they are mutually exclusive (cf. [`man 5 resolv.conf`](https://manpages.debian.org/stable/manpages/resolv.conf.5.en.html)).

**Example**

    "sys" => {
      [...SNIP...]
      "resolv" => {
        "servers" => [ "10.1.1.1","10.1.1.2" ],
        "domain" => "devops.test",
        "search" => "sub.devops.test devops.test",
        "options" => %w[debug rotate],
        "force" => true
      }
    }

