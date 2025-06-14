require "minitest/autorun"
require "announcements_map"

class AnnouncementsMap
  class TestLongitude < Minitest::Test
    def test_parse_valid_longitude
      lng = Longitude.parse("45.5")
      assert_equal 45.5, lng.to_f
    end

    def test_parse_invalid_format
      assert_raises(Longitude::InvalidError) do
        Longitude.parse("invalid")
      end
    end

    def test_parse_out_of_range
      assert_raises(Longitude::InvalidError) do
        Longitude.parse("181")
      end

      assert_raises(Longitude::InvalidError) do
        Longitude.parse("-181")
      end
    end

    def test_valid?
      assert Longitude.valid?("45.5")
      assert Longitude.valid?("180")
      assert Longitude.valid?("-180")
      assert Longitude.valid?(45.5)
      refute Longitude.valid?("181")
      refute Longitude.valid?("-181")
    end

    def test_comparison
      lng1 = Longitude.parse("45.0")
      lng2 = Longitude.parse("45.0")
      lng3 = Longitude.parse("50.0")

      assert_equal 0, lng1 <=> lng2
      assert_equal -1, lng1 <=> lng3
      assert_equal 1, lng3 <=> lng1
      assert lng1 == lng2
      assert lng1 < lng3
      assert lng3 > lng1
      assert lng1 <= lng2
      assert lng1 <= lng3
      assert lng3 >= lng1
      assert lng3 >= lng2
    end

    def test_comparison_with_invalid_type
      lng = Longitude.parse("45.0")
      assert_nil lng <=> "45.0"
    end
  end
end
