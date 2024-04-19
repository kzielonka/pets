class Auth 
  class Email
    ValidationError = Class.new(RuntimeError)

    def initialize(email)
      @email = String(email).strip.freeze
      raise ValidationError.new("email is too long") if @email.size > 1000
      raise ValidationError.new("email is too short") if @email.size < 4
    end

    def self.from(email)
      case email
      when Email then email
      when String then Email.new(email)
      else raise RuntimeError.new("invalid email")
      end
    end

    def self.random
      from("#{SecureRandom.uuid}@example.com")
    end

    def to_s
      @email
    end

    def ==(other)
      Email.from(other).to_s == @email
    end
  end
  private_constant :Email
end
