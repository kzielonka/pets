require "minitest/autorun"
require "announcements_map"

class TestMap < Minitest::Test
  def test_test
    map = AnnouncementsMap.new
    assert_equal [], map.search
  end
end
