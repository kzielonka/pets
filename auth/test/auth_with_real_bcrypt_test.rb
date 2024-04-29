require "minitest/autorun"
require "auth"
require "fake_time"

class TestAuthWithRealBcrypt < Minitest::Test
  
  def setup
    @fake_time = FakeTime.new
    @auth = Auth.new("hmac-secret", :in_memory, @fake_time, :bcrypt)
  end

  def test_sign_in
    email = "test@example.com"
    password = "password"
    @auth.sign_up(email, password)

    result = @auth.sign_in(email, password)
    assert result.authenticated?

    result = @auth.sign_in(email, "invalid")
    assert !result.authenticated?

    result = @auth.sign_in("test1234@example.com", password)
    assert !result.authenticated?
  end
end

