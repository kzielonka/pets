require "minitest/autorun"
require "announcements"

class Announcements
  class TestLocation < Minitest::Test

    def test_builds_from_hash
      location = Location.build({ latitude: 10.23, longitude: 43.52 })
      assert_equal 10.23, location.latitude
      assert_equal 43.52, location.longitude
    end

    def test_builds_from_location
      location = Location.build({ latitude: 10.23, longitude: 43.52 })
      other_location = Location.build(location)
      assert_equal location, other_location
    end

    def test_builds_zero_location
      location = Location.zero
      assert_equal 0, location.latitude
      assert_equal 0, location.longitude
    end

    def test_equality
      location1 = Location.new(1, 2)
      location2 = Location.new(1, 2)
      location3 = Location.new(3, 4)
      assert location1 == location2
      assert location1 != location3
    end

    def test_approximate_distance
      location1 = Location.new(1, 1)
      location2 = Location.new(2, 2)
      assert_in_delta 1.414, location1.approximate_distance_to(location2), 0.001
      assert_in_delta 1.414, location2.approximate_distance_to(location1), 0.001

      location3 = Location.new(-4, 10)
      location4 = Location.new(15, 21)
      assert_in_delta 21.954, location3.approximate_distance_to(location4), 0.001
    end
  end
end
