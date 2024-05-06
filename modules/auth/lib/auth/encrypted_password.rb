require "bcrypt"

class Auth
  class EncryptedPassword
    def initialize(password_hash, bcrypt)
      @password_hash = String(password_hash).dup.freeze
      @bcrypt = bcrypt
    end

    def self.from(obj)
      case obj
      when EncryptedPassword then obj
      when Password then obj.encrypted
      else raise RuntimeError.new("can not build encrypted password")
      end
    end

    def same?(password)
      @bcrypt.new_password(@password_hash) == String(password)
    end

    def encrypted
      self
    end

    def to_s
      @password_hash.to_s
    end

    protected
    
    def password_hash
      @password_hash
    end
  end
end
