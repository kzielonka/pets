require "test_helper"
require "integration_test"

class PublishAnnouncementTest < IntegrationTest
  test "announcement search" do
    Rails.application.config.announcements_search.reset!

    title = "title-#{Random.rand(1000)}"
    content = "content-#{Random.rand(1000)}"

    signed_in_user = sign_in_random_user

    signed_in_user.post "/users/me/announcements"
    announcements_public_id = JSON.parse(response.body)["id"]

    signed_in_user.patch "/users/me/announcements/#{announcements_public_id}", params: {
      title: title,
      content: content,
      location: { latitude: 12.34, longitude: -43.21 }
    }

    get "/announcements"
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body["announcements"].size

    signed_in_user.post "/users/me/announcements/#{announcements_public_id}/publish"

    get "/announcements"
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 1, parsed_body["announcements"].size
    assert_equal title, parsed_body["announcements"][0]["title"]
    assert_equal content, parsed_body["announcements"][0]["content"]
  end
end
