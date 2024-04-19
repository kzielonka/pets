class Auth
  class Credentials
    def initialize(user_id, email, password)
      @user_id = UserId.from(user_id)
      @email = Email.from(email)
      @password = Password.from(password)
    end

    attr_reader :user_id

    def self.random(email)
      random_user_id(email, Password.random)
    end

    def self.random_user_id(email, password)
      new(UserId.random, email, password)

    end

    def for_email?(email)
      Email.from(email) == @email
    end

    def matches_password?(password)
      Password.from(password).secure_equals?(@password)
    end
  end
  private_constant :Credentials
end
