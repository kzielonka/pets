# frozen_string_literal: true

require 'test_helper'
require 'integration_test'

class MapAnnouncementsTest < IntegrationTest
  test 'announcements map returns pin when announcement is published' do
    Rails.application.config.announcements_map.reset!

    signed_in_user = sign_in_random_user

    signed_in_user.post '/users/me/announcements'
    announcement_id = JSON.parse(response.body)['id']

    signed_in_user.patch "/users/me/announcements/#{announcement_id}", params: {
      title: 'Lost Cat',
      content: 'Near the park',
      location: { latitude: 52.23, longitude: 21.01 }
    }

    # Before publishing — map search within bounding box is empty
    get '/announcements/map', params: { top: 53.0, right: 22.0, bottom: 51.0, left: 20.0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body['pins'].size

    # Publish announcement
    signed_in_user.post "/users/me/announcements/#{announcement_id}/publish"
    assert_equal 200, response.status

    # Inside bounding box
    get '/announcements/map', params: { top: 53.0, right: 22.0, bottom: 51.0, left: 20.0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 1, parsed_body['pins'].size
    pin = parsed_body['pins'][0]
    assert_equal 'single_pin', pin['type']
    assert_equal announcement_id, pin['announcement_id']
    assert_in_delta 52.23, pin['location']['latitude'], 0.0001
    assert_in_delta 21.01, pin['location']['longitude'], 0.0001

    # Outside bounding box
    get '/announcements/map', params: { top: 10.0, right: 10.0, bottom: 0.0, left: 0.0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body['pins'].size

    # Unpublish announcement
    signed_in_user.post "/users/me/announcements/#{announcement_id}/unpublish"
    assert_equal 200, response.status

    get '/announcements/map', params: { top: 53.0, right: 22.0, bottom: 51.0, left: 20.0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 0, parsed_body['pins'].size
  end

  test 'announcements map clusters multiple nearby published announcements into group_pin' do
    Rails.application.config.announcements_map.reset!

    signed_in_user = sign_in_random_user

    # Publish announcement 1
    signed_in_user.post '/users/me/announcements'
    announcement_1_id = JSON.parse(response.body)['id']
    signed_in_user.patch "/users/me/announcements/#{announcement_1_id}", params: {
      title: 'Dog 1',
      content: 'Lost dog 1',
      location: { latitude: 52.20, longitude: 21.00 }
    }
    signed_in_user.post "/users/me/announcements/#{announcement_1_id}/publish"

    # Publish announcement 2 close to 1
    signed_in_user.post '/users/me/announcements'
    announcement_2_id = JSON.parse(response.body)['id']
    signed_in_user.patch "/users/me/announcements/#{announcement_2_id}", params: {
      title: 'Dog 2',
      content: 'Lost dog 2',
      location: { latitude: 52.22, longitude: 21.02 }
    }
    signed_in_user.post "/users/me/announcements/#{announcement_2_id}/publish"

    get '/announcements/map', params: { top: 60.0, right: 30.0, bottom: 40.0, left: 10.0 }
    assert_equal 200, response.status
    parsed_body = JSON.parse(response.body)
    assert_equal 1, parsed_body['pins'].size
    group_pin = parsed_body['pins'][0]
    assert_equal 'group_pin', group_pin['type']
    assert_equal 2, group_pin['number_of_pins']
    assert_in_delta 52.21, group_pin['location']['latitude'], 0.01
    assert_in_delta 21.01, group_pin['location']['longitude'], 0.01
  end

  test 'returns error searching map with missing or invalid bounding box params' do
    get '/announcements/map'
    assert_equal 400, response.status
    assert_equal({ 'error' => 'bounding-box-validation-error' }, JSON.parse(response.body))

    get '/announcements/map', params: { top: 'invalid', right: 20, bottom: 0, left: 0 }
    assert_equal 400, response.status
    assert_equal({ 'error' => 'bounding-box-validation-error' }, JSON.parse(response.body))
  end
end
