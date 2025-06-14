require "minitest/autorun"
require "announcements_map"

class AnnouncementsMap
  class TestLatitude < Minitest::Test
    def test_parse_valid_latitude
      lat = Latitude.parse("45.5")
      assert_equal 45.5, lat.to_f
    end

    def test_parse_invalid_format
      assert_raises(Latitude::InvalidError) do
        Latitude.parse("invalid")
      end
    end

    def test_parse_out_of_range
      assert_raises(Latitude::InvalidError) do
        Latitude.parse("91")
      end

      assert_raises(Latitude::InvalidError) do
        Latitude.parse("-91")
      end
    end

    def test_valid?
      assert Latitude.valid?("45.5")
      assert Latitude.valid?("90")
      assert Latitude.valid?("-90")
      assert Latitude.valid?(45.5)
      refute Latitude.valid?("91")
      refute Latitude.valid?("-91")
    end

    def test_comparison
      lat1 = Latitude.parse("45.0")
      lat2 = Latitude.parse("45.0")
      lat3 = Latitude.parse("50.0")

      assert_equal 0, lat1 <=> lat2
      assert_equal -1, lat1 <=> lat3
      assert_equal 1, lat3 <=> lat1
      assert lat1 == lat2
      assert lat1 < lat3
      assert lat3 > lat1
      assert lat1 <= lat2
      assert lat1 <= lat3
      assert lat3 >= lat1
      assert lat3 >= lat2
    end

    def test_comparison_with_invalid_type
      lat = Latitude.parse("45.0")
      assert_nil lat <=> "45.0"
    end
  end 
end
