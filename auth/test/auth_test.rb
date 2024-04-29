require "minitest/autorun"
require "auth"
require "fake_time"

class TestAuth < Minitest::Test
  
  def setup
    @fake_time = FakeTime.new
    @auth = Auth.new("hmac-secret", :in_memory, @fake_time, :fake)
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

  def test_authentication
    email1 = "test1@example.com"
    email2 = "test2@example.com"
    password = "password"
    @auth.sign_up(email1, password)
    @auth.sign_up(email2, password)
    user_1_access_token_1 = @auth.sign_in(email1, password).access_token
    user_1_access_token_2 = @auth.sign_in(email1, password).access_token
    user_2_access_token_1 = @auth.sign_in(email2, password).access_token
    user_2_access_token_2 = @auth.sign_in(email2, password).access_token
    assert @auth.authenticate(user_1_access_token_1).user_id == @auth.authenticate(user_1_access_token_2).user_id 
    assert @auth.authenticate(user_1_access_token_1).user_id != @auth.authenticate(user_2_access_token_1).user_id 
    assert @auth.authenticate(user_1_access_token_2).user_id != @auth.authenticate(user_2_access_token_2).user_id 
    assert @auth.authenticate(user_2_access_token_1).user_id == @auth.authenticate(user_2_access_token_2).user_id 
  end

  def test_token_expiration
    email = "test@example.com"
    password = "password"
    @auth.sign_up(email, password)
    access_token = @auth.sign_in(email, password).access_token
    assert @auth.authenticate(access_token).success?

    @fake_time.change(Time.new(2010, 1, 1, 0, 0, 0, 0))
    assert !@auth.authenticate(access_token).success?
  end

  def test_token_with_invalid_secret
    other_auth = Auth.new("hmac-secret-2", :in_memory, @fake_time)
    email = "test@example.com"
    password = "password"
    @auth.sign_up(email, password)
    other_auth.sign_up(email, password)
    access_token = @auth.sign_in(email, password).access_token
    other_access_token = other_auth.sign_in(email, password).access_token
    assert @auth.authenticate(access_token).success?
    assert !other_auth.authenticate(access_token).success?
    assert !@auth.authenticate(other_access_token).success?
    assert other_auth.authenticate(other_access_token).success?
  end

  def test_sign_in_with_invalid_not_matching_validation_criteria
    email = "test@example.com" * 1000
    password = "password"
    result = @auth.sign_in(email, password)
    assert !result.authenticated?
  end

  def test_sign_in_with_password_not_matching_validation_criteria
    email = "test@example.com"
    password = "password" * 1000
    result = @auth.sign_in(email, password)
    assert !result.authenticated?
  end
end
