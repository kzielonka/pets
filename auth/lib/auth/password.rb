class Auth
  class Password
    def initialize(password)
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

    def to_s
      @password
    end

    def secure_equals?(other)
      # TODO: add BCrypt
      Password.from(other).to_s == @password
    end
  end
  private_constant :Password
end
