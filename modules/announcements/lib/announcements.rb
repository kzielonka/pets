require "securerandom" 

require "announcements/errors"
require "announcements/users"
require "announcements/repos"
require "announcements/location"
require "announcements/announcement"
require "announcements/serialized_announcement"

class Announcements
  def initialize(events_bus, repo = :in_memory)
    @repo = Repos.build(repo)
    @events_bus = events_bus
  end

  def add_new_draft(user)
    user = Users.build(user)
    announcement = Announcement.draft_with_random_id.assign_owner(user.id)
    @repo.save(announcement)
    NewDraft.new(announcement.id)
  end

  def update_title(user, id, title)
    user = Users.build(user)
    @repo.find(id).change_title(user, title)
  end

  def update_content(user, id, content)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.change_content(user, content)
    @repo.save(announcement)
  end

  def update_location(user, id, location)
    user = Users.build(user)
    location = Location.build(location)
    announcement = @repo.find(id)
    announcement.change_location(user, location)
    @repo.save(announcement)
  end

  def publish(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.publish(user)
    @repo.save(announcement)
    @events_bus.publish(Events::AnnouncementPublished.new(id, announcement.title, announcement.content, announcement.location))
  end

  def unpublish(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.unpublish(user)
    @repo.save(announcement)
    @events_bus.publish(Events::AnnouncementUnpublished.new(id))
  end

  def fetch_private(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    if announcement.can_be_viewed_by?(user)
      FetchResult.new(false, announcement.draft?, announcement.title, announcement.content, announcement.location)
    else
      FetchResult.new(true, false, "", "", Location.zero)
    end
  end

  def fetch_all_for(user)
    user = Users.build(user)
    @repo.find_by_user(user).map do |announcement|
      AnnouncementData.new(announcement.id, announcement.draft?, announcement.title, announcement.content)
    end
  end

  NewDraft = Struct.new(:id)
  private_constant :NewDraft

  FetchResult = Struct.new(:not_found?, :draft?, :title, :content, :location)
  private_constant :FetchResult

  AnnouncementData = Struct.new(:id, :draft?, :title, :content)
  private_constant :AnnouncementData

  module Events
    class AnnouncementPublished
      def initialize(id, title, content, location)
        @id = String(id).dup.freeze
        @title = String(title).dup.freeze
        @content = String(content).dup.freeze
        @location = Location.build(location)
      end
      
      def type
        "AnnouncementPublished"
      end

      def payload
        {
          "id" => @id,
          "title" => @title,
          "content" => @content,
          "location" => {
            "latitude" => @location.latitude,
            "longitude" => @location.longitude,
          },
        }
      end
    end

    class AnnouncementUnpublished
      def initialize(id)
        @id = String(id).dup.freeze
      end

      def type
        "AnnouncementUnpublished"
      end

      def payload
        {
          "id" => @id
        }
      end
    end
  end
  private_constant :Events
end
