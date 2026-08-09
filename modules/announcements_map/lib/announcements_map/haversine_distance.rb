# frozen_string_literal: true

class AnnouncementsMap
  class HaversineDistance
    def initialize(lat1, lon1, lat2, lon2)
      @lat1 = Types.Latitude(lat1)
      @lon1 = Types.Longitude(lon1)
      @lat2 = Types.Latitude(lat2)
      @lon2 = Types.Longitude(lon2)
    end

    def km
      lat1 = @lat1.to_f
      lon1 = @lon1.to_f
      lat2 = @lat2.to_f
      lon2 = @lon2.to_f

      rad_per_deg = Math::PI / 180  # PI / 180
      earth_radius_km = 6371        # Earth radius in kilometers

      dlat_rad = (lat2 - lat1) * rad_per_deg # Delta, converted to rad
      dlon_rad = (lon2 - lon1) * rad_per_deg

      lat1_rad = lat1 * rad_per_deg
      lat2_rad = lat2 * rad_per_deg

      a = (Math.sin(dlat_rad / 2)**2) + (Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad / 2)**2))
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      earth_radius_km * c
    end
  end
end
