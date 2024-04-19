class Auth
  class AccessToken
    def initialize(user_id, issue_time, expiration_time)
      @user_id = user_id == :not_set ? :not_set : UserId.from(user_id)
      @issue_time = issue_time == :not_set ? :not_set : issue_time.to_time
      @expiration_time = expiration_time == :not_set ? :not_set : expiration_time.to_time
    end

    def self.blank
      new(:not_set, :not_set, :not_set)
    end

    def for_user(user_id)
      AccessToken.new(user_id, @issue_time, @expiration_time)
    end

    def issued_at(time)
      one_day = 60 * 60 * 24
      AccessToken.new(@user_id, time, time.to_time + one_day)
    end

    def jwt(hmac_secret)
      payload = {
        iat: @issue_time.to_i,
        nbf: @issue_time.to_i - 10,
        exp: @expiration_time.to_i,
        sub: @user_id,
        iss: "pets-app",
        aud: ["pets-app"]
      }
      jwt = JWT.encode(payload, hmac_secret, "HS256")
      JwtAccessToken.new(jwt)
    end
  end
end
