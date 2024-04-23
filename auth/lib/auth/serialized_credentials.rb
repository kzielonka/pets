class Auth
  class SerializedCredentials
    def initialize(user_id, email, password)
      @user_id = user_id
      @email = email
      @password = password
    end

    attr_reader :user_id, :email, :password

    def deserialize
      Credentials.new(@user_id, @email, @password)
    end
  end
end
