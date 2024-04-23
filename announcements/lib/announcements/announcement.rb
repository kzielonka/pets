class Announcements
  class Announcement
    def initialize(id, owner_id, draft, title, content)
      @id = String(id).dup.freeze
      @owner_id = String(owner_id).dup.freeze
      @draft = !!draft 
      @title = String(title).dup.freeze
      @content = String(content).dup.freeze
    end

    attr_reader :id, :title, :content

    def serialize
      SerializedAnnouncement.new(@id, @owner_id, @draft, @title, @content)
    end

    def draft?
      @draft
    end

    def has_id(id)
      @id == id
    end

    def self.draft(id)
      new(id, "", true, "", "")
    end

    def self.draft_with_random_id
      draft(SecureRandom.uuid)
    end

    def assign_owner(owner_id)
      @owner_id = String(owner_id).dup.freeze
      self
    end

    def change_title(user, title)
      user = Users.build(user)
      raise Errors::AuthorizationError.new unless can_be_managed_by?(user)
      @title = title
      self
    end

    def change_content(user, content)
      user = Users.build(user)
      raise Errors::AuthorizationError.new unless can_be_managed_by?(user)
      @content = content
      self
    end

    def publish(user)
      user = Users.build(user)
      raise Errors::AuthorizationError.new unless can_be_managed_by?(user)
      raise Errors::UnfinishedDraftError.new if @title == ""
      raise Errors::UnfinishedDraftError.new if @content == ""
      @draft = false
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
