require "test_helper"
require "integration_test"

class SigningInTest < IntegrationTest
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
end
