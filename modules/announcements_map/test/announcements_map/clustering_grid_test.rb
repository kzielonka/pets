require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestClusteringGrid < Minitest::Test
    def test_creates_empty_custering_grid
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)
      assert_equal [], cg.to_a
    end

    def test_returns_single_pin
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)
      cg.add_pin(Pin.parse('id', 2, 1))
      results = cg.to_a
      assert_equal 1, results.size
      assert_equal :single_pin, results[0].type
      assert_equal 'id', results[0].announcement_id

      # Verify memoization: subsequent calls return identical results
      assert_equal results, cg.to_a
      assert_equal 1, cg.count
    end

    def test_clusters_nearby_pins_into_group_and_keeps_distant_pin_single
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      # Two pins close together — should land in the same grid cell
      cg.add_pin(Pin.parse('id-1', 1.1, 1.1))
      cg.add_pin(Pin.parse('id-2', 1.2, 1.2))

      # One pin far away — different cell entirely
      cg.add_pin(Pin.parse('id-3', 8.0, 15.0))

      results = cg.to_a
      groups = results.select { |r| r.type == :group_pin }
      singles = results.select { |r| r.type == :single_pin }

      assert_equal 1, groups.size
      assert_equal 2, groups[0].number_of_pins

      assert_equal 1, singles.size
      assert_equal 'id-3', singles[0].announcement_id
    end

    def test_merges_adjacent_cells_when_centroids_are_within_range
      # Bounding box: 10° x 10°, grid = 10 cols x 20 rows
      # => each cell is 1° wide x 0.5° tall
      # => dynamic radius D = (10 - 0) * 0.08 = 0.8°
      # => vertically adjacent cells have centroids ~0.5° apart → within D → should merge
      bb = BoundingBoxBuilder.empty.top(10).right(10).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      # Pin in cell (1, 1) — latitude 0.2, longitude 0.5
      cg.add_pin(Pin.parse('id-1', 0.2, 0.5))

      # Pin in cell (1, 2) — latitude 0.7, longitude 0.5
      # Different cell, but centroid distance ~0.5° < D=0.8° → should merge with cell above
      cg.add_pin(Pin.parse('id-2', 0.7, 0.5))

      # Pin far away — should stay separate
      cg.add_pin(Pin.parse('id-3', 8.0, 8.0))

      results = cg.to_a
      groups = results.select { |r| r.type == :group_pin }
      singles = results.select { |r| r.type == :single_pin }

      # The two nearby pins (in adjacent cells) should be merged into one group
      assert_equal 1, groups.size
      assert_equal 2, groups[0].number_of_pins

      # The distant pin stays single
      assert_equal 1, singles.size
      assert_equal 'id-3', singles[0].announcement_id
    end

    def test_builds_two_separate_groups_and_one_isolated_pin
      # Bounding box: 10° x 10°, grid = 10 cols x 20 rows
      # Cell size: 1° wide x 0.5° tall
      # D ≈ 88.9 km ≈ ~0.8° latitude
      bb = BoundingBoxBuilder.empty.top(10).right(10).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      # Group 1 (bottom-left): 3 pins across 2 adjacent cells
      cg.add_pin(Pin.parse('g1-a', 0.2, 0.5))  # cell (1, 1)
      cg.add_pin(Pin.parse('g1-b', 0.3, 0.6))  # cell (1, 1) — same cell as g1-a
      cg.add_pin(Pin.parse('g1-c', 0.7, 0.5))  # cell (1, 2) — adjacent, within D → merges

      # Group 2 (top-right): 2 pins in adjacent cells
      cg.add_pin(Pin.parse('g2-a', 9.1, 9.1))  # cell (10, 19)
      cg.add_pin(Pin.parse('g2-b', 9.6, 9.2))  # cell (10, 20) — adjacent, within D → merges

      # Isolated pin in the middle — far from both groups
      cg.add_pin(Pin.parse('loner', 5.0, 5.0))

      results = cg.to_a
      groups = results.select { |r| r.type == :group_pin }.sort_by(&:number_of_pins).reverse
      singles = results.select { |r| r.type == :single_pin }

      # Two distinct groups
      assert_equal 2, groups.size
      assert_equal 3, groups[0].number_of_pins  # bottom-left group
      assert_equal 2, groups[1].number_of_pins  # top-right group

      # One isolated pin
      assert_equal 1, singles.size
      assert_equal 'loner', singles[0].announcement_id
    end

    def test_all_pins_far_apart_returns_only_single_pins
      bb = BoundingBoxBuilder.empty.top(10).right(10).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      cg.add_pin(Pin.parse('a', 1.0, 1.0))
      cg.add_pin(Pin.parse('b', 5.0, 5.0))
      cg.add_pin(Pin.parse('c', 9.0, 9.0))

      results = cg.to_a

      assert_equal 3, results.size
      assert(results.all? { |r| r.type == :single_pin })
      ids = results.map(&:announcement_id).sort
      assert_equal %w[a b c], ids
    end

    def test_group_pin_centroid_is_average_of_pin_coordinates
      bb = BoundingBoxBuilder.empty.top(10).right(10).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      # Two pins in adjacent cells that will merge
      cg.add_pin(Pin.parse('id-1', 0.2, 0.5))  # cell (1, 1)
      cg.add_pin(Pin.parse('id-2', 0.7, 0.5))  # cell (1, 2)

      results = cg.to_a

      assert_equal 1, results.size
      group = results[0]
      assert_equal :group_pin, group.type
      assert_in_delta 0.45, group.latitude.to_f, 0.00001   # (0.2 + 0.7) / 2
      assert_in_delta 0.5,  group.longitude.to_f, 0.00001  # (0.5 + 0.5) / 2
    end

    def test_chain_cells_only_merge_within_seed_radius
      # Cells A, B, C in a vertical line:
      #   A↔B centroids ~50 km apart  → within D (≈89 km) → merges
      #   B↔C centroids ~56 km apart  → within D → would merge if measured from B
      #   A↔C centroids ~106 km apart → BEYOND D → does NOT merge
      #
      # Since A has the most pins, it's the seed. C is compared against A's centroid,
      # not B's, so C stays separate.
      bb = BoundingBoxBuilder.empty.top(10).right(10).bottom(0).left(0).build
      cg = ClusteringGrid.new(bb)

      # Cell A: 2 pins → heaviest, becomes seed first
      cg.add_pin(Pin.parse('a1', 0.2, 0.5))  # cell (1, 1)
      cg.add_pin(Pin.parse('a2', 0.3, 0.5))  # cell (1, 1)

      # Cell B: 1 pin, adjacent to A, within D of A's centroid
      cg.add_pin(Pin.parse('b1', 0.7, 0.5))  # cell (1, 2)

      # Cell C: 1 pin, adjacent to B but beyond D from A's centroid
      cg.add_pin(Pin.parse('c1', 1.2, 0.5))  # cell (1, 3)

      results = cg.to_a
      groups = results.select { |r| r.type == :group_pin }
      singles = results.select { |r| r.type == :single_pin }

      # A + B merge (3 pins), C stays single
      assert_equal 1, groups.size
      assert_equal 3, groups[0].number_of_pins

      assert_equal 1, singles.size
      assert_equal 'c1', singles[0].announcement_id
    end
  end
end
