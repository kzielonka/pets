# frozen_string_literal: true

class AnnouncementsMap
  class Pin
    def self.parse(announcement_id, latitude, longitude)
      new(announcement_id, latitude, longitude)
    end

    def id
      @announcement_id
    end

    attr_reader :latitude, :longitude

    def distance_to(pin)
      latitude = Types::Latitude(pin.latitude)
      longitude = Types::Longitude(pin.longitude)
      haversine_distance(latitude, longitude)
    end

    private

    def initialize(announcement_id, latitude, longitude)
      @announcement_id = String(announcement_id)
      @latitude = Types::Latitude(latitude)
      @longitude = Types::Longitude(longitude)
    end

    def inspect
      "Pin(#{id}, #{latitude.to_f}, #{longitude.to_f})"
    end

    def haversine_distance(lat2, lon2)
      HaversineDistance.new(@latitude, @longitude, lat2, lon2).km
    end
  end
  private_constant :Pin
end
