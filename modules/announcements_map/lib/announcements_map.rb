require "announcements_map/latitude"
require "announcements_map/longitude"
require "announcements_map/pin"
require "announcements_map/types"
require "announcements_map/bounding_box"
require "announcements_map/repos"
require "announcements_map/search_results"
require "announcements_map/haversine_distance"

# The AnnouncementsMap class serves as the public facade for the Announcements Map module.
# It handles storing pin coordinates and performing spatial bounding box searches (e.g. for map rendering/clustering).
class AnnouncementsMap
  # Initializes the AnnouncementsMap facade.
  def initialize
    @repo = Repos.build(:in_memory)
  end

  # Searches for map pins within a geographic bounding box.
  #
  # @param top [Numeric] the maximum latitude (northern boundary).
  # @param right [Numeric] the maximum longitude (eastern boundary).
  # @param bottom [Numeric] the minimum latitude (southern boundary).
  # @param left [Numeric] the minimum longitude (western boundary).
  # @return [Array<SearchResults::SinglePin, SearchResults::GroupPin>] list of pins within the bounding box.
  def search(top, right, bottom, left)
    bb = Types.BoundingBoxBuilder.top(top).right(right).bottom(bottom).left(left).build
    pins = @repo.search(bb)
    pins.map { |pin| SearchResults::SinglePin.new(pin.id, pin.latitude, pin.longitude) }
  end

  # Adds a coordinates pin for an announcement to the map repo.
  #
  # @param announcement_id [String] the announcement identifier.
  # @param latitude [Numeric] latitude coordinate.
  # @param longitude [Numeric] longitude coordinate.
  # @return [void]
  def add_pin(announcement_id, latitude, longitude)
    announcement_id = String(announcement_id)
    latitude = Types.Latitude(latitude)
    longitude = Types.Longitude(longitude)
    pin = Pin.parse(announcement_id, latitude, longitude)
    @repo.save(pin)
  end
end
