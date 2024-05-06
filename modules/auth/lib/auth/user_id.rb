class Auth 
  class UserId
    InvalidUserIdError = Class.new(RuntimeError)

    def initialize(id)
      @id = String(id).dup.freeze
    end

    def self.from(user_id)
      case user_id
      when UserId then user_id
      when String then UserId.new(user_id)
      else raise InvalidUserIdError.new("invalid user_id")
      end
    end

    def self.random
      from(SecureRandom.uuid)
    end

    def to_s
      @id
    end

    def ==(other)
      UserId.from(other).id == @id
    rescue InvalidUserIdError
      false
    end

    protected

    def id
      @id
    end
  end
  private_constant :UserId
end
