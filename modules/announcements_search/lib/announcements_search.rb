require "announcements"
require "announcements_search/announcement"
require "announcements_search/repos"

# The AnnouncementsSearch class serves as the public facade for the Announcements Search module.
# It acts as a read model, subscribing to publication events and allowing spatial/location-based searches.
class AnnouncementsSearch
  # Initializes the AnnouncementsSearch facade.
  def initialize
    @repo = Repos.build(:in_memory)
  end

  # Searches for published announcements, ordered by distance to the specified location.
  #
  # @param location [Announcements::Location] the central location to compute distance from. Defaults to Announcements::Location.zero.
  # @return [Array<Announcement>] list of announcements ordered by geographic distance.
  def search(location = Announcements::Location.zero)
    @repo.search(location)
  end

  # Subscribes this read-model to the event bus, registering handlers for publish/unpublish events.
  #
  # @param events_bus [EventsBus] the system-wide event bus to subscribe to.
  # @return [void]
  def subscribe(events_bus)
    events_bus.register_subscriber(AnnouncementPublishedSubscriber.new(@repo))
    events_bus.register_subscriber(AnnouncementUnpublishedSubscriber.new(@repo))
  end

  # Resets/wipes the read model repository. Typically used between tests.
  #
  # @return [void]
  def reset!
    @repo.reset!
  end

  private

  class AnnouncementPublishedSubscriber
    def initialize(repo)
      @repo = repo
    end

    def handle(event)
      return unless event.type == "AnnouncementPublished"
      announcement = Announcement.blank(event.payload["id"])
        .with_title(event.payload["title"])
        .with_content(event.payload["content"])
        .with_location(Announcements::Location.new(event.payload["location"]["latitude"], event.payload["location"]["longitude"]))
      @repo.save(announcement)
    end
  end
  private_constant :AnnouncementPublishedSubscriber

  class AnnouncementUnpublishedSubscriber
    def initialize(repo)
      @repo = repo
    end

    def handle(event)
      return unless event.type == "AnnouncementUnpublished"
      id = event.payload["id"]
       @repo.delete(id)
    end
  end
  private_constant :AnnouncementUnpublishedSubscriber
end
