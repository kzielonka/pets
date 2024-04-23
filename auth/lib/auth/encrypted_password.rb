require "bcrypt"

class Auth
  class EncryptedPassword
    def initialize(password_hash)
      @password_hash = BCrypt::Password.new(password_hash)
    end

    def self.from(obj)
      case obj
      when EncryptedPassword then obj
      when Password then obj.encrypted
      when String then new(obj)
      else raise RuntimeError.new("can not build encrypted password")
      end
    end

    def same?(password)
      @password_hash == String(password)
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
