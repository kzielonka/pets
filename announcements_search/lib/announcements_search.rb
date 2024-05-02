require "announcements"

class AnnouncementsSearch
  def initialize
    @repo = Repos::InMemoryRepo.new
  end

  def search
    @repo.search
  end

  def handle_new_published_announcement(id:, title:, content:, location:)
    announcement = Announcement.blank(id)
      .with_title(title)
      .with_content(content)
      .with_location(location)
    @repo.save(announcement)
  end

  module Repos
    class InMemoryRepo
      def initialize
        @announcements = []
      end

      def save(announcement)
        @announcements << announcement
      end

      def search
        @announcements
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
