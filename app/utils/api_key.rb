require "digest/md5"

class ApiKey
  def self.compute(plaintext_password)
    Digest::MD5.hexdigest("stringer:#{plaintext_password}")
  end
end
