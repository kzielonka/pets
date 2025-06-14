class AnnouncementsMap
  class BoundingBox
    class InvalidCoordinatesError < ArgumentError; end

    def initialize(top, right, bottom, left)
      @top = Types::Latitude(top)
      @right = Types::Longitude(right)
      @bottom = Types::Latitude(bottom)
      @left = Types::Longitude(left)
    rescue ArgumentError, Latitude::InvalidError, Longitude::InvalidError
      raise InvalidCoordinatesError.new("Invalid bounding box coordinates")
    end

    attr_reader :top, :right, :bottom, :left

    def contains?(latitude, longitude)
      latitude = Types::Latitude(latitude)
      longitude = Types::Longitude(longitude)
      #TODO: case when pin is on edge
      return latitude <= @top && latitude >= @bottom && longitude <= @right && longitude >= @left
    end
  end
end
