# frozen_string_literal: true

require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMapTests < Minitest::Test
  def test_search_for_pins_when_no_pins_have_been_added_yet
    @announcements = AnnouncementsMap.new
    result = @announcements.search(10, 10, -10, -10)
    assert result.empty?
  end

  def test_search_for_pins
    @announcements = AnnouncementsMap.new
    @announcements.add_pin('id-1', 10, 10)
    @announcements.add_pin('id-2', 8, 9)
    @announcements.add_pin('id-3', -2, -3)

    result1 = @announcements.search(10, 10, -10, -10)
    result2 = @announcements.search(0, 0, -10, -10)

    assert result1.size == 3
    assert_has_single_pin(result1, 'id-1', 10, 10)
    assert_has_single_pin(result1, 'id-2', 8, 9)
    assert_has_single_pin(result1, 'id-3', -2, -3)

    assert result2.size == 1
    assert_has_single_pin(result2, 'id-3', -2, -3)
  end

  def test_search_for_pins_in_groups
    @announcements = AnnouncementsMap.new
    @announcements.add_pin('id-1', 10, 10)
    @announcements.add_pin('id-2', 9.9, 9.9)
    @announcements.add_pin('id-3', 9.8, 9.8)
    @announcements.add_pin('id-4', 9.7, 9.5)
    result = @announcements.search(10, 10, 0, 0)
    assert_equal 1, result.size
    assert_has_group_pin(result, 4, 9.85, 9.8)
  end

  private

  def assert_has_single_pin(pins, announcement_id, latitude, longitude)
    found = pins.any? do |pin|
      pin.type == :single_pin &&
        pin.announcement_id == announcement_id &&
        (pin.latitude.to_f - latitude.to_f).abs < 0.00001 &&
        (pin.longitude.to_f - longitude.to_f).abs < 0.00001
    end
    assert found, "Expected to find single pin for #{announcement_id} at (#{latitude}, #{longitude}) in #{pins.inspect}"
  end

  def assert_has_group_pin(pins, pins_number, latitude, longitude)
    found = pins.any? do |pin|
      pin.type == :group_pin &&
        pin.number_of_pins == pins_number &&
        (pin.latitude.to_f - latitude.to_f).abs < 0.00001 &&
        (pin.longitude.to_f - longitude.to_f).abs < 0.00001
    end
    assert found, "Expected to find group pin of #{pins_number} at (#{latitude}, #{longitude}) in #{pins.inspect}"
  end

  def assert_single_pin(pin, announcement_id, latitude, longitude)
    assert_equal :single_pin, pin.type
    assert_equal announcement_id, pin.announcement_id
    assert_in_delta latitude, pin.latitude.to_f, 0.00001
    assert_in_delta longitude, pin.longitude.to_f, 0.00001
  end

  def assert_group_pin(pin, pins_number, latitude, longitude)
    assert_equal :group_pin, pin.type
    assert_equal pins_number, pin.number_of_pins
    assert_in_delta latitude, pin.latitude.to_f, 0.00001
    assert_in_delta longitude, pin.longitude.to_f, 0.00001
  end
end
