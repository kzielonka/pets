# frozen_string_literal: true

require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestBoundingBox < Minitest::Test
    def test_calcualtes_distance_width_and_height_for_point
      bb = Types.BoundingBoxBuilder.top(0).left(0).right(0).bottom(0).build
      assert_equal 0, bb.width_in_km
      assert_equal 0, bb.height_in_km
    end

    def test_calcualtes_distance_width_and_height
      bb = Types.BoundingBoxBuilder.top(4).left(2).right(3).bottom(1).build
      assert_in_delta 110.924, bb.width_in_km
      assert_in_delta 333.584, bb.height_in_km
    end
  end
end
