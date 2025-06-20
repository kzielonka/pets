class AnnouncementsMap
  class Pin
    def self.parse(announcement_id, latitude, longitude)
      new(announcement_id, latitude, longitude)
    end
    
    def id
      @announcement_id
    end

    attr_reader :latitude, :longitude

    private 

    def initialize(announcement_id, latitude, longitude)
      @announcement_id = String(announcement_id)
      @latitude = Types::Latitude(latitude)
      @longitude = Types::Longitude(longitude)
    end

    def inspect
      "Pin(#{id}, #{latitude.to_f}, #{longitude.to_f})"
    end
  end
  private_constant :Pin
end
