# frozen_string_literal: true

require 'set'

class AnnouncementsMap
  class Grid
    def initialize(width, height, bounding_box)
      @width = Integer(width)
      @height = Integer(height)
      @bounding_box = Types::BoundingBox(bounding_box)
      # Outer array is width (columns / X), inner array is height (rows / Y)
      @grid = Array.new(@width) { Array.new(@height) { [] } }
      @added_ids = Set.new
    end

    attr_reader :width, :height

    def add_pin(pin)
      raise ArgumentError, "Pin with ID '#{pin.id}' has already been added to the grid" if @added_ids.include?(pin.id)

      col = calc_col_index(pin)
      row = calc_row_index(pin)
      @grid[col][row].push(pin)
      @added_ids.add(pin.id)
    end

    def number_of_pins(x, y)
      validate_coords!(x, y)
      @grid[x - 1][y - 1].size
    end

    # Returns the average [lat, lon] of pins in the cell, or the geographic center of the cell if empty
    def centroid_of(x, y)
      validate_coords!(x, y)
      pins = @grid[x - 1][y - 1]

      if pins.empty?
        col = x - 1
        row = y - 1
        width_deg = @bounding_box.width.to_f
        height_deg = @bounding_box.height.to_f

        lon = width_deg.positive? ? @bounding_box.left.to_f + ((col + 0.5) * (width_deg / @width)) : @bounding_box.left.to_f
        lat = height_deg.positive? ? @bounding_box.bottom.to_f + ((row + 0.5) * (height_deg / @height)) : @bounding_box.bottom.to_f
        [lat, lon]
      else
        avg_lat = pins.sum { |p| p.latitude.to_f } / pins.size
        avg_lon = pins.sum { |p| p.longitude.to_f } / pins.size
        [avg_lat, avg_lon]
      end
    end

    # Returns raw pins in the cell (returns a copy to ensure encapsulation)
    def pins_in(x, y)
      validate_coords!(x, y)
      @grid[x - 1][y - 1].dup
    end

    private

    def validate_coords!(x, y)
      x = Integer(x)
      y = Integer(y)
      raise ArgumentError if x > @width || x < 1 || y > @height || y < 1
    end

    def calc_col_index(pin)
      raise ArgumentError, "Longitude #{pin.longitude.to_f} is out of bounding box (left: #{@bounding_box.left.to_f}, right: #{@bounding_box.right.to_f})" if pin.longitude < @bounding_box.left || pin.longitude > @bounding_box.right

      width_deg = @bounding_box.width.to_f
      return 0 if width_deg <= 0

      col = ((pin.longitude.to_f - @bounding_box.left.to_f) / width_deg * @width).to_i
      [col, @width - 1].min # Clamp to avoid out-of-bounds at boundary
    end

    def calc_row_index(pin)
      raise ArgumentError, "Latitude #{pin.latitude.to_f} is out of bounding box (bottom: #{@bounding_box.bottom.to_f}, top: #{@bounding_box.top.to_f})" if pin.latitude < @bounding_box.bottom || pin.latitude > @bounding_box.top

      height_deg = @bounding_box.height.to_f
      return 0 if height_deg <= 0

      row = ((pin.latitude.to_f - @bounding_box.bottom.to_f) / height_deg * @height).to_i
      [row, @height - 1].min # Clamp to avoid out-of-bounds at boundary
    end
  end
end
