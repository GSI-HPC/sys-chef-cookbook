Encrypt data with a nodes public key, and decrypt upon deployment. 

↪ `libraries/secret.rb`

## Example

Lets assume you want to deploy a shared secret on a group of nodes.
The secret will be generated and encrypted on one of these nodes 
called `lxserv01`:

    class Chef::Recipe
      include Sys::Secret
    end
    
    case node.hostname 
    when 'lxserv01'
      secret = "A Secret String"
      # holds the encrypted data for all nodes
      node.default_unless[:secrets] = Hash.new
      # search for all nodes sharing the secret
      search(:node,'name:lxnodes*').each do |n|
        # encrypt the secret for each node using the public key
        node.normal[:secrets][n.fqdn] = encrypt(secret,n.fqdn)
      end
    when /lxnodes[1-9].*/
      # get the encrypted data
      secrets = search(:node,'name:lxserv01*').secrets
      # decrypt with the nodes private key
      secret = decrypt(secrets[node.fqdn])
    end


