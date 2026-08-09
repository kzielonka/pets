# frozen_string_literal: true

require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestSearchAlg < Minitest::Test
    def test_calcualtes_distance_to_itself
      pin = Pin.parse('announcement_id', 10, 20)
      assert_equal 0, pin.distance_to(pin)
    end
  end
end
