class AnnouncementsSearch
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

    def self.random_id
      blank(SecureRandom.uuid)
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

    def approximate_distance_to(location)
      @location.approximate_distance_to(location)
    end
  end
  private_constant :Announcement
end

