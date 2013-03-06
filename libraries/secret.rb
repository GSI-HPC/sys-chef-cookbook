require 'openssl'
require 'base64'

module Secret
  def getApiClientPubKey(clientname)
    client = Chef::Search::Query.new.search(:client,"name:#{clientname}")[0]
    client -= [nil]
    Chef::Log.info("found client: #{client}")
    if client[0].nil?
      Chef::Log.info("Failed to load public key of #{clientname}")
      return nil
    else
      return OpenSSL::PKey::RSA.new(client[0].public_key)
    end
  end

  def encrypt(plaintext,clientname)
    # choose a cipher
    cipher = OpenSSL::Cipher::Cipher.new 'AES-256-CFB'
    # initialize the cipher for encrypting
    cipher.encrypt
    # choose random initialization vector
    iv = cipher.random_iv
    # choose random key for encryption
    key = cipher.random_key
    # encrypt the file the file with the AES-Key and save it in a file
    secret_enc = cipher.update(plaintext) + cipher.final
    # Base64-encode the ciphtertext
    ciphertext = Base64.encode64(secret_enc)
    # Load the public key of the client
    public_key = getApiClientPubKey(clientname)
    unless public_key.nil?
      # encrypt initialization vector and key with RSA-public-key
      iv_enc = Base64.encode64(public_key.public_encrypt(iv))
      key_enc = Base64.encode64(public_key.public_encrypt(key))
      # return array of encrypted iv and key
      return [iv_enc, key_enc, ciphertext]
    else
      Chef::Log.warn("Could not find public key of #{clientname}")
      return nil
    end
  end

  # secretArray contains the ciphertext, and the AES-Key encrypted by the RSA-public-key of the client
  # secretArray[0]: encrypted initialization vector
  # secretArray[1]: encrypted key
  # secretArray[2]: encrypted secret
  def decrypt(secretArray)
    # get private key
    private_key = OpenSSL::PKey::RSA.new(File.read('/etc/chef/client.pem'))
    Chef::Log.warn("secret array: #{secretArray}")
    unless secretArray.nil?
      # decrypt symmetric key
      iv_plain = private_key.private_decrypt(Base64.decode64(secretArray[0]))
      key_plain = private_key.private_decrypt(Base64.decode64(secretArray[1]))
      # choose a cipher
      decipher = OpenSSL::Cipher::Cipher.new 'AES-256-CFB'
      # initialize the cipher for encrypting
      decipher.decrypt
      # set initialization vector
      decipher.iv = iv_plain
      # set decryption key
      decipher.key = key_plain
      # get ciphertext from Base64 encoding
      secret_enc = Base64.decode64(secretArray[2])
      # decode ciphertext
      return decipher.update(secret_enc) + decipher.final
    else
      Chef::Log.info("secretArray was empty")
    end
  end
end
