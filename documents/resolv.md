Configure Domain Name Service (DNS) resolution.

↪ `attributes/resolv.rb`  
↪ `recipes/resolv.rb`  
↪ `templates/*/etc_resolv.conf.erb`  

**Attributes**

All attributes in `node.sys.resolv`:


* `servers` (required) list a DNS server hosts.
* `domain` (optional) local domain name.
* `search` (optional) list for host-name lookup.

**Example**

    "sys" => {
      [...SNIP...]
      "resolv" => {
        "servers" => [ "10.1.1.1","10.1.1.2" ],
        "domain" => "devops.test",
        "search" => "sub.devops.test devops.test"
      }
    }

