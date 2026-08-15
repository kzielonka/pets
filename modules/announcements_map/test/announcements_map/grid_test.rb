# frozen_string_literal: true

require 'minitest/autorun'
require 'announcements_map'

class AnnouncementsMap
  class TestGrid < Minitest::Test
    def test_creates_grid_with_specified_size
      bb = BoundingBoxBuilder.empty.top(1).right(1).bottom(2).left(1).build
      grid = Grid.new(2, 3, bb)
      assert_equal 0, grid.number_of_pins(1, 1)
      assert_equal 0, grid.number_of_pins(2, 1)
      assert_equal 0, grid.number_of_pins(1, 2)
      assert_equal 0, grid.number_of_pins(2, 2)
      assert_equal 0, grid.number_of_pins(1, 3)
      assert_equal 0, grid.number_of_pins(2, 3)
      assert_raises(ArgumentError) { grid.number_of_pins(0, 0) }
      assert_raises(ArgumentError) { grid.number_of_pins(3, 1) }
      assert_raises(ArgumentError) { grid.number_of_pins(4, 4) }
    end

    def test_adds_pin_to_proper_cell
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)
      grid.add_pin(Pin.parse("id", 3, 4))
      assert_equal 0, grid.number_of_pins(1, 1)
      assert_equal 0, grid.number_of_pins(1, 2)
      assert_equal 0, grid.number_of_pins(2, 1)
      assert_equal 1, grid.number_of_pins(5, 4)
    end

    def test_handles_swapped_dimensions_safely
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)
      
      # latitude = 3.0 (row = 3), longitude = 16.0 (col = 16)
      grid.add_pin(Pin.parse("id-large-lon", 3.0, 16.0))
      assert_equal 1, grid.number_of_pins(17, 4)
    end

    def test_handles_pins_on_boundaries_safely
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      # Pin exactly on the top-right boundary
      grid.add_pin(Pin.parse("id-boundary", 10.0, 20.0))
      assert_equal 1, grid.number_of_pins(20, 10)
    end

    def test_centroid_of_calculates_average_coordinates
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      grid.add_pin(Pin.parse("id-1", 1.0, 1.0))
      grid.add_pin(Pin.parse("id-2", 1.5, 1.2)) # Both fall in cell (2, 2)

      lat, lon = grid.centroid_of(2, 2)
      assert_in_delta 1.25, lat, 0.00001
      assert_in_delta 1.1, lon, 0.00001
    end

    def test_pins_in_returns_raw_pins
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      pin1 = Pin.parse("id-1", 1.0, 1.0)
      pin2 = Pin.parse("id-2", 1.2, 1.2)
      grid.add_pin(pin1)
      grid.add_pin(pin2)

      pins = grid.pins_in(2, 2)
      assert_equal 2, pins.size
      assert_includes pins, pin1
      assert_includes pins, pin2
    end

    def test_centroid_of_empty_cell_returns_geographic_center_of_cell
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      # Cell (2, 2) is 1-based: col index 1, row index 1.
      # Width degree per cell is 20/20 = 1.0. Latitude degree per cell is 10/10 = 1.0.
      # Center of cell (2, 2) should be lat = 1.5, lon = 1.5.
      lat, lon = grid.centroid_of(2, 2)
      assert_in_delta 1.5, lat, 0.00001
      assert_in_delta 1.5, lon, 0.00001
    end

    def test_add_pin_out_of_bounds_raises_informative_error
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      error1 = assert_raises(ArgumentError) do
        grid.add_pin(Pin.parse("id-out-lat", 12.0, 5.0))
      end
      assert_match(/Latitude 12.0 is out of bounding box/i, error1.message)

      error2 = assert_raises(ArgumentError) do
        grid.add_pin(Pin.parse("id-out-lon", 5.0, 25.0))
      end
      assert_match(/Longitude 25.0 is out of bounding box/i, error2.message)
    end

    def test_pins_in_returns_copy_of_array
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      pin = Pin.parse("id", 1.0, 1.0)
      grid.add_pin(pin)

      pins = grid.pins_in(2, 2)
      pins.clear # Mutate the returned array

      assert_equal 1, grid.number_of_pins(2, 2)
    end

    def test_add_duplicate_pin_id_raises_error
      bb = BoundingBoxBuilder.empty.top(10).right(20).bottom(0).left(0).build
      grid = Grid.new(20, 10, bb)

      grid.add_pin(Pin.parse("id-1", 1.0, 1.0))
      
      error = assert_raises(ArgumentError) do
        grid.add_pin(Pin.parse("id-1", 2.0, 2.0))
      end
      assert_match(/Pin with ID 'id-1' has already been added/i, error.message)
    end
  end
end
