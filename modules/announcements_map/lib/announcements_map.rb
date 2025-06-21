require "announcements_map/latitude"
require "announcements_map/longitude"
require "announcements_map/pin"
require "announcements_map/types"
require "announcements_map/bounding_box"
require "announcements_map/repos"
require "announcements_map/search_results"

class AnnouncementsMap
  def initialize
    @repo = Repos.build(:in_memory)
  end

  def search(top, right, bottom, left)
    bb = Types.BoundingBoxBuilder.top(top).right(right).bottom(bottom).left(left).build
    pins = @repo.search(bb)
    return pins.map { |pin| SearchResults::SinglePin.new(pin.id, pin.latitude, pin.longitude) }
  end

  def add_pin(announcement_id, latitude, longitude)
    announcement_id = String(announcement_id)
    latitude = Types.Latitude(latitude)
    longitude = Types.Longitude(longitude)
    pin = Pin.parse(announcement_id, latitude, longitude)
    @repo.save(pin)
  end
end
