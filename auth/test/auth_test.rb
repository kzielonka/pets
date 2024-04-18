require "minitest/autorun"
require "auth"

class TestAuth < Minitest::Test
  
  def setup
    @auth = Auth.new
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
