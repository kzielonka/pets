require "test_helper"
require "integration_test"

class SearchAnnouncementsTest < IntegrationTest
  test "announcement search returns one announcement when it is published" do
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

    get "/announcements", params: { latitude: 0, longitude: 0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body["announcements"].size

    signed_in_user.post "/users/me/announcements/#{announcements_public_id}/publish"

    get "/announcements", params: { latitude: 0, longitude: 0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 1, parsed_body["announcements"].size
    assert_equal title, parsed_body["announcements"][0]["title"]
    assert_equal content, parsed_body["announcements"][0]["content"]

    signed_in_user.post "/users/me/announcements/#{announcements_public_id}/unpublish"
    get "/announcements", params: { latitude: 0, longitude: 0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body["announcements"].size
  end

  test "announcement search returns announcement sorted by distance to provided location" do
    Rails.application.config.announcements_search.reset!

    signed_in_user = sign_in_random_user

    signed_in_user.post "/users/me/announcements"
    announcement_1_id = JSON.parse(response.body)["id"]
    signed_in_user.patch "/users/me/announcements/#{announcement_1_id}", params: {
      title: "announcement on 10",
      content: "content",
      location: { latitude: 0, longitude: 10 }
    }
    signed_in_user.post "/users/me/announcements/#{announcement_1_id}/publish"

    signed_in_user.post "/users/me/announcements"
    announcement_2_id = JSON.parse(response.body)["id"]
    signed_in_user.patch "/users/me/announcements/#{announcement_2_id}", params: {
      title: "announcement on 25",
      content: "content",
      location: { latitude: 0, longitude: 25 }
    }
    signed_in_user.post "/users/me/announcements/#{announcement_2_id}/publish"

    signed_in_user.post "/users/me/announcements"
    announcement_3_id = JSON.parse(response.body)["id"]
    signed_in_user.patch "/users/me/announcements/#{announcement_3_id}", params: {
      title: "announcement on 30",
      content: "content",
      location: { latitude: 0, longitude: 30 }
    }
    signed_in_user.post "/users/me/announcements/#{announcement_3_id}/publish"

    get "/announcements", params: { latitude: 0, longitude: 11 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 3, parsed_body["announcements"].size
    assert_equal "announcement on 10", parsed_body["announcements"][0]["title"]
    assert_equal "announcement on 25", parsed_body["announcements"][1]["title"]
    assert_equal "announcement on 30", parsed_body["announcements"][2]["title"]

    get "/announcements", params: { latitude: 0, longitude: 27 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 3, parsed_body["announcements"].size
    assert_equal "announcement on 25", parsed_body["announcements"][0]["title"]
    assert_equal "announcement on 30", parsed_body["announcements"][1]["title"]
    assert_equal "announcement on 10", parsed_body["announcements"][2]["title"]
  end

  test "returns error searching with no location" do
    Rails.application.config.announcements_search.reset!

    get "/announcements"
    assert_equal 400, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal({ "error" => "location-validation-error" }, parsed_body)
  end

  test "returns error searching with invalid latitude" do
    Rails.application.config.announcements_search.reset!

    get "/announcements", params: { latitude: "invalid", longitude: 0 }
    assert_equal 400, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal({ "error" => "location-validation-error" }, parsed_body)
  end

  test "returns error searching with invalid longitude" do
    Rails.application.config.announcements_search.reset!

    get "/announcements", params: { latitude: 0, longitude: "invalid" }
    assert_equal 400, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal({ "error" => "location-validation-error" }, parsed_body)
  end
end
