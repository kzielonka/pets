class AnnouncementsMap
  module Types
    def self.BoundingBoxBuilder
      return BoundingBoxBuilder.empty
    end

    def self.BoundingBox(bb)
      case bb
      when BoundingBox then return bb
      when BoundingBoxBuilder then return bb.build
      else raise RuntimeError("it is not valid bounding box")
      end
    end

    def self.Latitude(latitude)
      case latitude
      when Latitude then return latitude
      else Latitude.parse(latitude)
      end
    end

    def self.Longitude(longitude)
      case longitude
      when Longitude then return longitude
      else Longitude.parse(longitude)
      end
    end
  end
end
