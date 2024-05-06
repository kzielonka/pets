require "announcements"
require "announcements_search/announcement"
require "announcements_search/repos"

class AnnouncementsSearch
  def initialize
    @repo = Repos.build(:in_memory)
  end

  def search(location = Announcements::Location.zero)
    @repo.search(location)
  end

  def subscribe(events_bus)
    events_bus.register_subscriber(AnnouncementPublishedSubscriber.new(@repo))
    events_bus.register_subscriber(AnnouncementUnpublishedSubscriber.new(@repo))
  end

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
