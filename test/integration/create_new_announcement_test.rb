require "test_helper"
require "integration_test"

class CreateNewAnnouncementTest < IntegrationTest
  test "user creates, updates and publishes announcement" do
    signed_in_user = sign_in_random_user

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
    signed_in_user = sign_in_random_user
    other_signed_in_user = sign_in_random_user
    signed_in_user.post "/users/me/announcements"
    id = JSON.parse(response.body)["id"]
    other_signed_in_user.get "/users/me/announcements/#{id}"
    assert_equal 404, response.status
  end

  test "responds with user all announcements" do
    signed_in_user1 = sign_in_random_user
    signed_in_user2 = sign_in_random_user

    id1 = signed_in_user1.publish_announcement("title1", "content1")
    id2 = signed_in_user1.publish_announcement("title2", "content2")
    id3 = signed_in_user2.publish_announcement("title3", "content3")

    signed_in_user1.get "/users/me/announcements"
    assert_equal 200, response.status
    assert_equal [
      {
        "id" => id1,
        "draft" => false,
        "title" => "title1",
        "content" => "content1"
      }, {
        "id" => id2,
        "draft" => false,
        "title" => "title2",
        "content" => "content2"
      }
    ], JSON.parse(response.body)

    signed_in_user2.get "/users/me/announcements"
    assert_equal 200, response.status
    assert_equal [
      {
        "id" => id3,
        "draft" => false,
        "title" => "title3",
        "content" => "content3"
      }
    ], JSON.parse(response.body)
  end
end
