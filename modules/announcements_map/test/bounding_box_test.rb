require "minitest/autorun"
require "announcements_map"

class AnnouncementsMap
    class TestBoundingBox < Minitest::Test
        def test_initialization_with_valid_floats
            box = AnnouncementsMap::BoundingBox.new(10.0, 20.0, 30.0, 40.0)
            assert_equal Types::Latitude(10.0), box.top
            assert_equal Types::Longitude(20.0), box.right
            assert_equal Types::Latitude(30.0), box.bottom
            assert_equal Types::Longitude(40.0), box.left
        end

        def test_initialization_with_invalid_inputs
            assert_raises(AnnouncementsMap::BoundingBox::InvalidCoordinatesError) { AnnouncementsMap::BoundingBox.new("INVALID", 0.0, 10.0, 0.0) }
            assert_raises(AnnouncementsMap::BoundingBox::InvalidCoordinatesError) { AnnouncementsMap::BoundingBox.new(10.0, "INVALID", 10.0, 0.0) }
            assert_raises(AnnouncementsMap::BoundingBox::InvalidCoordinatesError) { AnnouncementsMap::BoundingBox.new(10.0, 0.0, "INVALID", 0.0) }
            assert_raises(AnnouncementsMap::BoundingBox::InvalidCoordinatesError) { AnnouncementsMap::BoundingBox.new(10.0, 0.0, 10.0, "INVALID") }
        end

        def test_contains_point
            box = AnnouncementsMap::BoundingBox.new(10.0, 20.0, -30.0, -40.0)
            
            # Points inside the box
            assert box.contains?(5.0, 5.0)
            assert box.contains?(0.0, 0.0)
            assert box.contains?(10.0, 10.0)
            assert box.contains?(0.0, 10.0)
            assert box.contains?(10.0, 0.0)
            
            # Points outside the box
            refute box.contains?(11.0, 5.0)  # North
            refute box.contains?(0.0, 21.0)  # South
            refute box.contains?(-31.0, 11.0)  # East
            refute box.contains?(5.0, -41.0)  # West
        end
    end 
end
