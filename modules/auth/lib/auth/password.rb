# frozen_string_literal: true

class Auth
  class Password
    ValidationError = Class.new(RuntimeError)

    def initialize(password, bcrypt)
      raise ValidationError, 'password is too long' if password.size > 1000

      @password = String(password).dup.freeze
      @bcrypt = bcrypt
    end

    def self.from(password)
      case password
      when Password then password
      else raise 'invalid password'
      end
    end

    def encrypted
      EncryptedPassword.new(@bcrypt.encrypt_raw(@password), @bcrypt)
    end

    def to_s
      @password
    end
  end
  private_constant :Password
end
