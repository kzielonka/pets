require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestClusteringGrid < Minitest::Test
    def test_creates_custering_grid
      cg = ClusteringGrid.new
    end
  end
end
