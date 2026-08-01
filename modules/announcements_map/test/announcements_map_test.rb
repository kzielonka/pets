require "minitest/autorun"
require "announcements_map"

class AnnouncementsMapTests < Minitest::Test
  def test_search_for_pins_when_no_pins_have_been_added_yet
    @announcements = AnnouncementsMap.new
    result = @announcements.search(10, 10, -10, -10)
    assert result.size == 0
  end

  def test_search_for_pins
    @announcements = AnnouncementsMap.new
    @announcements.add_pin("id-1", 10, 10)
    @announcements.add_pin("id-2", 8, 9)
    @announcements.add_pin("id-3", -2, -3)

    result1 = @announcements.search(10, 10, -10, -10)
    result2 = @announcements.search(0, 0, -10, -10)

    assert result1.size == 3
    assert_has_single_pin(result1, "id-1", 10, 10)
    assert_has_single_pin(result1, "id-2", 8, 9)
    assert_has_single_pin(result1, "id-3", -2, -3)

    assert result2.size == 1
    assert_has_single_pin(result2, "id-3", -2, -3)
  end

  def test_search_for_pins_in_groups
    @announcements = AnnouncementsMap.new
    @announcements.add_pin("id-1", 10, 10)
    @announcements.add_pin("id-2", 9.9, 9.9)
    @announcements.add_pin("id-3", 9.8, 9.8)
    @announcements.add_pin("id-4", 9.7, 9.5)
    result = @announcements.search(10, 10, 0, 0)
    assert result.size == 1
    assert_has_group_pin(result, "announcement_id", 9.5, 9.5)
  end

  private

  def assert_has_single_pin(pins, announcement_id, latitude, longitude)
    pins.any? do |pin| 
      assert_single_pin(pin, announcement_id, latitude, longutde)
      true
    rescue 
      false
    end
  end

  def assert_has_group_pin(pins, pins_number, latitude, longitude)
    pins.any? do |pin| 
      assert_group_pin(pin, pins_number, latitude, longutde)
      true
    rescue 
      false
    end
  end

  def assert_single_pin(pin, announcement_id, latitude, longitude)
    assert pin.type == :single_pin
    assert pin.announcement_id == "announcement_id"
    assert pin.latitude.to_f == latitude
    assert pin.longitude.to_f == longitude
  end

  def assert_group_pin(pin, pins_number, latitude, longitude)
    assert pin.type == :group_pin
    assert pin.number_of_pins == pins_number
    assert pin.latitude.to_f == latitude
    assert pin.longitude.to_f == longitude
  end
end

