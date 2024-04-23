class Auth
  class Credentials
    def initialize(user_id, email, password)
      @user_id = UserId.from(user_id)
      @email = Email.from(email)
      @password = EncryptedPassword.from(password)
    end

    attr_reader :user_id

    def serialize
      SerializedCredentials.new(@user_id, @email, @password)
    end

    def self.random
      new(UserId.random, Email.random, Password.random)
    end

    def self.random_user_id(email, password)
      random.for_email(email).with_password(password)
    end

    def for_email(email)
      Credentials.new(@user_id, email, @password)
    end

    def for_user(user_id)
      Credentials.new(user_id, @email, @password)
    end

    def with_password(password)
      Credentials.new(@user_id, @email, password)
    end

    def for_email?(email)
      Email.from(email) == @email
    end

    def for_user?(user_id)
      UserId.from(user_id) == @user_id
    end

    def matches_password?(password)
      @password.same?(password)
    end
  end
  private_constant :Credentials
end
