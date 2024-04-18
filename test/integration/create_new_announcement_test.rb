require "test_helper"

class CreateNewAnnouncementTest < ActionDispatch::IntegrationTest
  test "user creates, updates and publishes announcement" do
    post "/users/me/announcements"
    announcements_public_id = JSON.parse(response.body)["id"]

    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title",
    }
    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "", parsed_body["content"] 
    
    patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content"
    }
    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: "title2",
    }
    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content", parsed_body["content"] 

    patch "/users/me/announcements/#{announcements_public_id}", params: {
      content: "content2",
    }
    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal true, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 

    post "/users/me/announcements/#{announcements_public_id}/publish"
    get "/users/me/announcements/#{announcements_public_id}"
    parsed_body = JSON.parse(response.body)
    assert_equal false, parsed_body["draft"] 
    assert_equal "title2", parsed_body["title"] 
    assert_equal "content2", parsed_body["content"] 
  end
end
