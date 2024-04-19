require "minitest/autorun"
require "auth"

class TestAuth < Minitest::Test
  
  def setup
    @auth = Auth.new("hmac-secret")
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
end
