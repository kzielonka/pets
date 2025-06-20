require "minitest/autorun"
require "announcements_map"

class AnnouncementsMap
  module Repos
    module ContractTests
      def test_saves_pin
        pin = Pin.parse("announcement_id", 10, 20)
        @repo.save(pin)
        pins = @repo.search(BoundingBoxBuilder.empty.top(30).right(30).left(-30).bottom(-30))
        assert pins.size == 1
        assert pins.first.latitude == Types::Latitude(10)
        assert pins.first.longitude == Types::Longitude(20)
      end

      def test_search_pin_by_bounding_box
        pin1 = Pin.parse("announcement_1_id", 10, 20)
        pin2 = Pin.parse("announcement_2_id", 20, 30)

        @repo.save(pin1)
        @repo.save(pin2)

        pins1 = @repo.search(BoundingBoxBuilder.empty.top(10).right(20).left(20).bottom(10))
        pins2 = @repo.search(BoundingBoxBuilder.empty.top(20).right(30).left(30).bottom(20))
        pins1and2 = @repo.search(BoundingBoxBuilder.empty.top(20).right(30).left(20).bottom(10))
        no_pins = @repo.search(BoundingBoxBuilder.empty.top(0).right(0).left(0).bottom(0))

        assert pins1.size == 1
        assert pins1.first.latitude == Types::Latitude(10)
        assert pins1.first.longitude == Types::Longitude(20)

        assert pins2.size == 1
        assert pins2.first.latitude == Types::Latitude(20)
        assert pins2.first.longitude == Types::Longitude(30)

        assert pins1and2.size == 2

        assert no_pins.size == 0
      end
    end

    class TestInMemoryRepo < Minitest::Test
      include ContractTests

      def setup
        @repo = Repos.build(:in_memory)
      end
    end
  end
end
