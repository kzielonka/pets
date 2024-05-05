require "announcements"

class AnnouncementsSearch
  def initialize
    @repo = Repos::InMemoryRepo.new
  end

  def search
    @repo.search
  end

  def subscribe(events_bus)
    events_bus.register_subscriber(AnnouncementPublishedSubscriber.new(@repo))
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

  module Repos
    class InMemoryRepo
      def initialize
        reset!
      end

      def save(announcement)
        @announcements << announcement
      end

      def search
        @announcements
      end

      def reset!
        @announcements = []
      end
    end
  end
  private_constant :Repos

  class Announcement
    def initialize(id, title, content, location)
      @id = id
      @title = title
      @content = content
      @location = Announcements::Location.build(location)
    end

    attr_reader :id, :title, :content, :location

    def self.blank(id)
      new(id, "", "", Announcements::Location.zero)
    end

    def with_title(title)
      self.class.new(@id, title, @content, @location)
    end

    def with_content(content)
      self.class.new(@id, @title, content, @location)
    end

    def with_location(location)
      self.class.new(@id, @title, @content, location)
    end
  end
end
