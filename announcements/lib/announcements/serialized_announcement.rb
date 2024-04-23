class Announcements
  class SerializedAnnouncement

    def initialize(id, owner_id, draft, title, content)
      @id = id
      @owner_id = owner_id
      @draft = draft
      @title = title
      @content = content
    end

    attr_reader :id, :owner_id, :draft, :title, :content

    def deserialize
      Announcement.new(@id, @owner_id, @draft, @title, @content)
    end
  end
end
