# frozen_string_literal: true

require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestPin < Minitest::Test
    def test_calcualtes_distance_to_itself
      pin = Pin.parse('announcement_id', 10, 20)
      assert_equal 0, pin.distance_to(pin)
    end

    def test_calcualtes_distance_between_two_pins
      pin1 = Pin.parse('announcement_1_id', 10, 20)
      pin2 = Pin.parse('announcement_2_id', 30, 40)
      assert_in_delta 3040.60281, pin1.distance_to(pin2)
    end
  end
end
