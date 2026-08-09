# frozen_string_literal: true

class AnnouncementsMap
  module Types
    def self.Pin(pin)
      case pin
      when Pin then pin
      else raise 'it is not a pin'
      end
    end

    def self.BoundingBoxBuilder
      BoundingBoxBuilder.empty
    end

    def self.BoundingBox(bb)
      case bb
      when BoundingBox then bb
      when BoundingBoxBuilder then bb.build
      else raise 'it is not valid bounding box'
      end
    end

    def self.Latitude(latitude)
      case latitude
      when Latitude then latitude
      else Latitude.parse(latitude)
      end
    end

    def self.Longitude(longitude)
      case longitude
      when Longitude then longitude
      else Longitude.parse(longitude)
      end
    end
  end
end
