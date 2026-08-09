# frozen_string_literal: true

class Announcements
  class Announcement
    def initialize(id, owner_id, draft, title, content, location)
      @id = String(id).dup.freeze
      @owner_id = String(owner_id).dup.freeze
      @draft = !draft.nil?
      @title = String(title).dup.freeze
      @content = String(content).dup.freeze
      @location = location
    end

    attr_reader :id, :title, :content, :location

    def serialize
      SerializedAnnouncement.new(@id, @owner_id, @draft, @title, @content, @location)
    end

    def draft?
      @draft
    end

    def has_id(id)
      @id == id
    end

    def self.draft(id)
      new(id, '', true, '', '', Location.zero)
    end

    def self.draft_with_random_id
      draft(SecureRandom.uuid)
    end

    def assign_owner(owner_id)
      @owner_id = String(owner_id).dup.freeze
      self
    end

    def subscribers(subscriber)
      @subscribers << subscriber
    end

    def change_title(user, title)
      user = Users.build(user)
      raise Errors::AuthorizationError unless can_be_managed_by?(user)
      raise Errors::CanNotEditPublishedAnnouncementError unless draft?

      @title = String(title).dup.freeze
      self
    end

    def change_content(user, content)
      user = Users.build(user)
      raise Errors::AuthorizationError unless can_be_managed_by?(user)
      raise Errors::CanNotEditPublishedAnnouncementError unless draft?

      @content = content
      self
    end

    def change_location(user, location)
      user = Users.build(user)
      location = Location.build(location)
      raise Errors::AuthorizationError unless can_be_managed_by?(user)
      raise Errors::CanNotEditPublishedAnnouncementError unless draft?

      @location = location
      self
    end

    def publish(user)
      user = Users.build(user)
      raise Errors::AuthorizationError unless can_be_managed_by?(user)
      raise Errors::UnfinishedDraftError if @title == ''
      raise Errors::UnfinishedDraftError if @content == ''
      raise RuntimeError unless @draft

      @draft = false
      self
    end

    def unpublish(user)
      user = Users.build(user)
      raise Errors::AuthorizationError unless can_be_managed_by?(user)
      raise RuntimeError if @draft

      @draft = true
      self
    end

    def public?
      !@draft
    end

    def can_be_viewed_by?(user)
      can_be_managed_by?(user)
    end

    def belongs_to?(user)
      user = Users.build(user)
      @owner_id == user.id
    end

    private

    def can_be_managed_by?(user)
      user.system? || belongs_to?(user)
    end
  end
  private_constant :Announcement
end
