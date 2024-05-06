class Auth
  class JwtAccessToken
    def initialize(jwt)
      @jwt = String(jwt).dup.freeze
      @payload = nil
    end

    def to_s
      @jwt
    end

    def valid?(secret, now)
      now = now.to_time
      payload, _ = JWT.decode(@jwt, secret, true, algorithms: "HS256", exp_leeway: 60 * 60 * 24 * 365 * 100, nbf_leeway: 60 * 60 * 24 * 365)
      payload["exp"] > now.to_i && payload["nbf"] <= now.to_i
    rescue JWT::VerificationError 
      return false
    end

    def user_id
      UserId.from(payload["sub"])
    end

    private

    def payload 
      return @payload if @payload
      @payload, _ = JWT.decode(@jwt, nil, false)
      @payload
    end
  end
end
