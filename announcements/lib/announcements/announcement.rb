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

    def has_id(id)
      @id == id
    end

    def self.draft
      new(SecureRandom.uuid, "", true, "", "")
    end

    def assign_owner(owner_id)
      @owner_id = owner_id
      self
    end

    def change_title(user, title)
      @title = title
      self
    end

    def change_content(user, content)
      @content = content
    end

    def publish
      @draft = false
    end

    def public?
      !@draft
    end
  end
  private_constant :Announcement
end
