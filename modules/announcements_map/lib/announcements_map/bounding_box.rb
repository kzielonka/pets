# frozen_string_literal: true

class AnnouncementsMap
  class BoundingBoxBuilder
    def self.empty
      BoundingBoxBuilder.new(Types::Latitude(0), Types::Longitude(0), Types::Latitude(0), Types::Longitude(0))
    end

    def top(top)
      BoundingBoxBuilder.new(Types::Latitude(top), @right, @bottom, @left)
    end

    def right(right)
      BoundingBoxBuilder.new(@top, Types::Longitude(right), @bottom, @left)
    end

    def bottom(bottom)
      BoundingBoxBuilder.new(@top, @right, Types::Latitude(bottom), @left)
    end

    def left(left)
      BoundingBoxBuilder.new(@top, @right, @bottom, Types::Longitude(left))
    end

    def build
      BoundingBox.new(@top, @right, @bottom, @left)
    end

    private

    def initialize(top, right, bottom, left)
      @top = top
      @right = right
      @bottom = bottom
      @left = left
    end
  end

  class BoundingBox
    class InvalidCoordinatesError < ArgumentError; end

    def initialize(top, right, bottom, left)
      @top = Types::Latitude(top)
      @right = Types::Longitude(right)
      @bottom = Types::Latitude(bottom)
      @left = Types::Longitude(left)
      # TODO: validate that top >= bototm and right >= left
    rescue ArgumentError, Latitude::InvalidError, Longitude::InvalidError
      raise InvalidCoordinatesError, 'Invalid bounding box coordinates'
    end

    attr_reader :top, :right, :bottom, :left

    def width
      @right - @left
    end

    def height
      @top - @bottom
    end

    def width_in_km
      HaversineDistance.new(@top, @left, @top, @right).km
    end

    def height_in_km
      HaversineDistance.new(@top, @left, @bottom, @left).km
    end

    def contains?(latitude, longitude)
      latitude = Types::Latitude(latitude)
      longitude = Types::Longitude(longitude)
      # TODO: case when pin is on edge
      latitude <= @top && latitude >= @bottom && longitude <= @right && longitude >= @left
    end
  end
end
