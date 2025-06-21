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
    @announcements.add_pin("announcement_id", 10, 10)
    result = @announcements.search(10, 10, -10, -10)
    assert result.size == 1
    assert_has_single_pin(result, "announcement_id", 10, 10)
  end

  private

  def assert_has_single_pin(pins, announcement_id, latitude, longitude)
    pins.any? do |pin| 
      begin
        assert_single_pin(pin, announcement_id, latitude, longutde)
        true
      rescue 
        false
      end
    end
  end

  def assert_single_pin(pin, announcement_id, latitude, longitude)
    assert pin.type == :single_pin
    assert pin.announcement_id == "announcement_id"
    assert pin.latitude.to_f == 10
    assert pin.longitude.to_f == 10
  end
end

