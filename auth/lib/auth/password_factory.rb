require "bcrypt"
require "digest"

class Auth
  class PasswordFactory
    def initialize(bcrypt)
      @bcrypt = bcrypt
    end

    def self.build(type)
      case type
      when :bcrypt then new(BCrypt.new)
      when :fake_crypt, :fake then new(FakeCrypt.new)
      else RuntimeError.new "unregistered password encryptor #{type}"
      end
    end

    def raw_password(password)
      Password.new(password, @bcrypt)
    end

    def random
      raw_password(SecureRandom.uuid)
    end
    
    def encrypted_password(password)
      EncryptedPassword.new(password, @bcrypt)
    end

    class BCrypt
      def new_password(password_hash)
        ::BCrypt::Password.new(password_hash)
      end

      def encrypt_raw(password)
        ::BCrypt::Password.create(password)
      end
    end
    private_constant :BCrypt

    class FakeCrypt
      def new_password(password_hash)
        FakePassword.new(password_hash)
      end

      def encrypt_raw(password) 
        random_hex = SecureRandom.hex(10)
        "#{password}#{random_hex}"
        digest = Digest::MD5.hexdigest "#{password}#{random_hex}"
        "#{digest}:#{random_hex}"
      end

      class FakePassword
        def initialize(password_hash)
          @password_hash = password_hash
        end

        def ==(other)
          other = String(other)
          splited = @password_hash.split(":")
          hashed_password = splited[0]
          random_hex = splited[1]
          Digest::MD5.hexdigest("#{other}#{random_hex}") == hashed_password
        end
      end
      private_constant :FakePassword
    end
    private_constant :FakeCrypt
  end
end
