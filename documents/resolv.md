Configure Domain Name Service (DNS) resolution.

↪ `attributes/resolv.rb`  
↪ `recipes/resolv.rb`  
↪ `templates/*/etc_resolv.conf.erb`  

**Attributes**

All attributes in `node.sys.resolv`:

| Attribute | Type | mandatory | Descripton |
|---|---|---|---|
| `servers` | Array | yes | list a DNS server IPs |
| `domain` | String | no | local domain name |
| `search` | Array or String | no | list for host-name lookup |
| `options` | Array | no | list of options |
| `force` | Boolean, default: false | no |  make sys::resolv overwrite `/etc/resolv.conf` even though it is a link (eg. managed by resolvconf) |

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

