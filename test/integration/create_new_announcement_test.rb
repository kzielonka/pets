require "test_helper"
require "integration_test"

class CreateNewAnnouncementTest < IntegrationTest
  test "user creates, updates and publishes announcement" do
    post "/sign_in", params: { email: "test@example.com", password: "PAssword1234$" }
    access_token = JSON.parse(response.body)["accessToken"]

    signed_in_user = user(access_token)

    signed_in_user.post "/users/me/announcements"
    announcements_public_id = JSON.parse(response.body)["id"]

    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 

    signed_in_user.patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title",
    }
    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 
    
    signed_in_user.patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content"
    }

    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    signed_in_user.patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title2",
    }
    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    signed_in_user.patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content2",
    }
    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 

    signed_in_user.post "/users/me/announcements/#{announcements_public_id}/publish"
    signed_in_user.get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal false, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 
  end

  test "responds with 404 trying to get not existing announcement" do
    get "/users/me/announcements/id", headers: { "AUTHORIZATION" => "Bearer 1234" }
    assert_equal 404, response.status
  end

  test "responds with 404 trying to edit someone else order" do
    signed_in_user = sign_in("test@example.com", "PAssword1234$")
    other_signed_in_user = sign_in("other@example.com", "PAssword1234$")
    signed_in_user.post "/users/me/announcements"
    id = JSON.parse(response.body)["id"]
    other_signed_in_user.get "/users/me/announcements/#{id}"
    assert_equal 404, response.status
  end
end
