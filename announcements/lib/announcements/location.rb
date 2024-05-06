class Announcements
  class Location
    def initialize(latitude, longitude)
      @latitude = latitude.to_f
      @longitude = longitude.to_f
    end

    def self.build(obj)
      case obj
      when Location then obj
      when Hash then Location.new(obj[:latitude], obj[:longitude])
      else raise RuntimeError.new "can not build Location from #{obj.inspect}"
      end
    end

    def self.zero
      Location.new(0, 0)
    end

    attr_reader :latitude, :longitude

    def ==(other)
      other.is_a?(Location) && @latitude == other.latitude && @longitude == other.longitude
    end

    def approximate_distance_to(location)
      Math.sqrt((location.latitude - @latitude)**2 + (location.longitude - @longitude)**2)
    end
  end
end
