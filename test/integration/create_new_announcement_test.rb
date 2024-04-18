require "test_helper"

class CreateNewAnnouncementTest < ActionDispatch::IntegrationTest
  test "user creates, updates and publishes announcement" do
    post "/sign_in", params: { email: "test@example.com", password: "PAssword1234$" }
    access_token = JSON.parse(response.body)["accessToken"]

    post "/users/me/announcements", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    announcements_public_id = JSON.parse(response.body)["id"]

    get "/users/me/announcements/#{announcements_public_id}", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title",
    }, headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    get "/users/me/announcements/#{announcements_public_id}", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 
    
    patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content"
    }, headers: { "AUTHORIZATION" => "Bearer #{access_token}" }

    get "/users/me/announcements/#{announcements_public_id}", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title2",
    }, headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    get "/users/me/announcements/#{announcements_public_id}", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content2",
    }, headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    get "/users/me/announcements/#{announcements_public_id}", headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 

    post "/users/me/announcements/#{announcements_public_id}/publish",
      headers: { "AUTHORIZATION" => "Bearer #{access_token}" }
    get "/users/me/announcements/#{announcements_public_id}",
      headers: { "AUTHORIZATION" => "Bearer #{access_token}" }

    parsed_body = JSON.parse(response.body)
    assert_equal false, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 
  end

  test "responds with 404 trying to get un existing announcement" do
    get "/users/me/announcements/id", headers: { "AUTHORIZATION" => "Bearer 1234" }
    assert_equal 404, response.status
  end
end
