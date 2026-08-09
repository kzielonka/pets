# frozen_string_literal: true

require 'securerandom'

require 'announcements/errors'
require 'announcements/users'
require 'announcements/repos'
require 'announcements/location'
require 'announcements/announcement'
require 'announcements/serialized_announcement'

# The Announcements class serves as the public facade for the Announcements module.
# It encapsulates managing draft creation, updates, public publishing/unpublishing, and private data retrieval.
class Announcements
  # Initializes the Announcements facade.
  #
  # @param events_bus [EventsBus] the system-wide event bus for dispatching domain events.
  # @param repo [Symbol] the database repository strategy, either :in_memory or :active_record.
  def initialize(events_bus, repo = :in_memory)
    @repo = Repos.build(repo)
    @events_bus = events_bus
  end

  # Creates a new empty announcement draft owned by the specified user.
  #
  # @param user [String, User] user identifier or object representing the owner.
  # @return [NewDraft] DTO containing the auto-generated uuid of the new draft (id).
  def add_new_draft(user)
    user = Users.build(user)
    announcement = Announcement.draft_with_random_id.assign_owner(user.id)
    @repo.save(announcement)
    NewDraft.new(announcement.id)
  end

  # Updates the title of a draft announcement.
  #
  # @param user [String, User] user invoking the action (must be owner or system).
  # @param id [String] the announcement identifier.
  # @param title [String] the new title.
  # @raise [Announcements::Errors::AuthorizationError] if user is not authorized.
  # @raise [Announcements::Errors::CanNotEditPublishedAnnouncementError] if the announcement is already published.
  # @return [void]
  def update_title(user, id, title)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.change_title(user, title)
    @repo.save(announcement)
  end

  # Updates the content text of a draft announcement.
  #
  # @param user [String, User] user invoking the action (must be owner or system).
  # @param id [String] the announcement identifier.
  # @param content [String] the new content description.
  # @raise [Announcements::Errors::AuthorizationError] if user is not authorized.
  # @raise [Announcements::Errors::CanNotEditPublishedAnnouncementError] if the announcement is already published.
  # @return [void]
  def update_content(user, id, content)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.change_content(user, content)
    @repo.save(announcement)
  end

  # Updates the location coordinates of a draft announcement.
  #
  # @param user [String, User] user invoking the action (must be owner or system).
  # @param id [String] the announcement identifier.
  # @param location [Hash, Location] the new coordinates e.g. { latitude: Float, longitude: Float }.
  # @raise [Announcements::Errors::AuthorizationError] if user is not authorized.
  # @raise [Announcements::Errors::CanNotEditPublishedAnnouncementError] if the announcement is already published.
  # @return [void]
  def update_location(user, id, location)
    user = Users.build(user)
    location = Location.build(location)
    announcement = @repo.find(id)
    announcement.change_location(user, location)
    @repo.save(announcement)
  end

  # Publishes a draft announcement, making it public, and broadcasts an AnnouncementPublished event.
  #
  # @param user [String, User] user invoking the action (must be owner or system).
  # @param id [String] the announcement identifier.
  # @raise [Announcements::Errors::AuthorizationError] if user is not authorized.
  # @raise [Announcements::Errors::UnfinishedDraftError] if either title or content is empty.
  # @return [void]
  def publish(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.publish(user)
    @repo.save(announcement)
    @events_bus.publish(Events::AnnouncementPublished.new(id, announcement.title, announcement.content,
                                                          announcement.location))
  end

  # Unpublishes a published announcement, reverting it back to a draft, and broadcasts an AnnouncementUnpublished event.
  #
  # @param user [String, User] user invoking the action (must be owner or system).
  # @param id [String] the announcement identifier.
  # @raise [Announcements::Errors::AuthorizationError] if user is not authorized.
  # @return [void]
  def unpublish(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    announcement.unpublish(user)
    @repo.save(announcement)
    @events_bus.publish(Events::AnnouncementUnpublished.new(id))
  end

  # Fetches details of an announcement for its owner or the system.
  #
  # @param user [String, User] user invoking the request (must be owner or system).
  # @param id [String] the announcement identifier.
  # @return [FetchResult] DTO containing not_found? (Boolean), draft? (Boolean), title (String), content (String), and location (Location).
  def fetch_private(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    if announcement.can_be_viewed_by?(user)
      FetchResult.new(false, announcement.draft?, announcement.title, announcement.content, announcement.location)
    else
      FetchResult.new(true, false, '', '', Location.zero)
    end
  end

  # Fetches brief information for all announcements owned by a user.
  #
  # @param user [String, User] user identifier or object.
  # @return [Array<AnnouncementData>] array of DTOs containing id, draft?, title, content.
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
        'AnnouncementPublished'
      end

      def payload
        {
          'id' => @id,
          'title' => @title,
          'content' => @content,
          'location' => {
            'latitude' => @location.latitude,
            'longitude' => @location.longitude
          }
        }
      end
    end

    class AnnouncementUnpublished
      def initialize(id)
        @id = String(id).dup.freeze
      end

      def type
        'AnnouncementUnpublished'
      end

      def payload
        {
          'id' => @id
        }
      end
    end
  end
  private_constant :Events
end
