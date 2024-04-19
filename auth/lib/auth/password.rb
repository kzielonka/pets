class Auth
  class Password
    ValidationError = Class.new(RuntimeError)

    def initialize(password)
      raise ValidationError.new("password is too long") if password.size > 1000
      @password = String(password).dup.freeze
    end

    def self.from(password)
      case password
      when Password then password
      when String then Password.new(password)
      else raise RuntimeError.new("invalid password")
      end
    end

    def self.random
      from(SecureRandom.uuid)
    end

    def encrypted
      EncryptedPassword.new(BCrypt::Password.create(@password))
    end

    def to_s
      @password
    end
  end
  private_constant :Password
end
