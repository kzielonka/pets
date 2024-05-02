require "minitest/autorun"
require "auth"
require "fake_time"

class TestSignUpValidation < Minitest::Test
  
  def setup
    @fake_time = FakeTime.new
    @auth = Auth.new("hmac-secret", :in_memory, @fake_time, :fake)
  end

  def test_email_is_too_long
    email = "t" * 1000 + "@example.com"
    password = "password"
    assert_raises(Auth::Errors::ValidationError) do
      @auth.sign_up(email, password)
    end
  end

  def test_email_is_too_short
    email = "a@b"
    password = "password"
    assert_raises(Auth::Errors::ValidationError) do
      @auth.sign_up(email, password)
    end
  end

  def test_email_is_too_short_if_it_contains_spaces
    email = "      a@b        "
    password = "password"
    assert_raises(Auth::Errors::ValidationError) do
      @auth.sign_up(email, password)
    end
  end

  def test_password_is_too_long
    email = "test@example.com"
    password = "PAssword1234$" * 1000
    assert_raises(Auth::Errors::ValidationError) do
      @auth.sign_up(email, password)
    end
  end
end
