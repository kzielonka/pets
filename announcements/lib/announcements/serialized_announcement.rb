class Announcements
  class SerializedAnnouncement

    def initialize(id, owner_id, draft, title, content, location)
      @id = id
      @owner_id = owner_id
      @draft = draft
      @title = title
      @content = content
      @location = location
    end

    attr_reader :id, :owner_id, :draft, :title, :content, :location

    def deserialize
      Announcement.new(@id, @owner_id, @draft, @title, @content, @location)
    end
  end
  private_constant :SerializedAnnouncement
end
