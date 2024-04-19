require "test_helper"
require "integration_test"

class SigningInTest < IntegrationTest
  setup do 
    Rails.application.config.auth.reset!
  end
  
  test "user signs up and signs in when email and password is correct" do
    email = "email@example.com"
    password = "password"

    post "/sign_up", params: { email: email, password: password } 
    assert_equal 200, response.status

    post "/sign_in", params: { email: email, password: password } 
    assert_equal 200, response.status

    post "/sign_in", params: { email: "other@example.com", password: password } 
    assert_equal 401, response.status

    post "/sign_in", params: { email: email, password: "PAssword1234$" } 
    assert_equal 401, response.status
  end
  
  test "user signs up, signs in and get access token" do
    email = "email@example.com"
    password = "password"

    post "/sign_up", params: { email: email, password: password } 
    post "/sign_in", params: { email: email, password: password } 
    access_token = JSON.parse(response.body)["accessToken"]
    
    post "/users/me/announcements", headers: { "Authorization": "Bearer #{access_token}" }
    assert_equal 200, response.status
  end

  test "user got error trying to sign up with email of existing other user" do
    email = "email@example.com"
    password = "password"

    post "/sign_up", params: { email: email, password: password } 
    assert_equal 200, response.status

    post "/sign_up", params: { email: email, password: password } 
    assert_equal 400, response.status
    assert_equal({ "error" => "duplicated-email" }, JSON.parse(response.body))
  end

  test "user got error trying to sign up with too long email" do
    email = "e"*1000 + "@example.com"
    password = "password"

    post "/sign_up", params: { email: email, password: password } 
    assert_equal 400, response.status
    assert_equal({
      "error" => "validation-error",
      "debugMessage" => "email is too long"
    }, JSON.parse(response.body))
  end

  test "user got error trying to sign up with too long password" do
    email = "test@example.com"
    password = "PAssword1234$" * 1000

    post "/sign_up", params: { email: email, password: password } 
    assert_equal 400, response.status
    assert_equal({
      "error" => "validation-error",
      "debugMessage" => "password is too long"
    }, JSON.parse(response.body))
  end

  test "user got error trying to sign in with too long password" do
    email = "test@example.com"
    password = "PAssword1234$" * 1000

    post "/sign_in", params: { email: email, password: password } 
    assert_equal 401, response.status
  end
end
