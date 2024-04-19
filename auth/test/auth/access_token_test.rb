require "minitest/autorun"
require "auth"

class Auth
  class TestAccessToken < Minitest::Test

    def test_jwt_has_right_payload_params
      time = Time.new(2000, 1, 1, 0, 0, 0, 0)

      jwt = AccessToken
        .blank
        .for_user("user-id")
        .issued_at(time)
        .jwt("secret")

      payload, _ = JWT.decode jwt.to_s, nil, false

      assert_equal "user-id", payload["sub"]
      assert_equal time.to_i, payload["iat"]
      assert_equal time.to_i - 10, payload["nbf"] 
      assert_equal Time.new(2000, 1, 2, 0, 0, 0, 0).to_i, payload["exp"]
      assert_equal "pets-app", payload["iss"]
      assert_equal ["pets-app"], payload["aud"]
    end

    def test_verify_access_token_is_signed_with_right_key
      access_token = AccessToken
        .blank
        .for_user("user-id")
        .issued_at(Time.new(2000, 1, 1, 0, 0, 0, 0))

      assert access_token.jwt("secret").valid?("secret", Time.new(2000, 1, 1, 10, 0, 0, 0))
      assert !access_token.jwt("secret").valid?("other secret", Time.new(2000, 1, 1, 10, 0, 0, 0))
    end

    def test_verify_access_token_is_not_expired
      secret = "secret"

      access_token = AccessToken
        .blank
        .for_user("user-id")
        .issued_at(Time.new(2000, 1, 1, 0, 0, 0, 0))

      assert access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 1, 10, 0, 0, 0))
      assert access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 1, 23, 59, 59, 0))
      assert !access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 2, 0, 0, 1, 0))
      assert !access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 2, 10, 0, 0, 0))
    end

    def test_verify_access_token_is_not_used_too_early
      secret = "secret"

      access_token = AccessToken
        .blank
        .for_user("user-id")
        .issued_at(Time.new(2000, 1, 10, 0, 0, 0, 0))

      assert access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 10, 0, 0, 0, 0))
      assert access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 10, 0, 0, 1, 0))
      assert access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 9, 23, 59, 51, 0))
      assert !access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 9, 0, 0, 0, 0))
      assert !access_token.jwt(secret).valid?(secret, Time.new(2000, 1, 9, 23, 59, 49, 0))
    end

    def test_jwt_sub
      access_token = AccessToken
        .blank
        .for_user("user-id")
        .issued_at(Time.new(2000, 1, 10, 0, 0, 0, 0))

      assert_equal UserId.from("user-id"), access_token.jwt("secret").user_id 
    end
  end
end
