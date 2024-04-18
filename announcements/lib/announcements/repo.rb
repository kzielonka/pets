class Announcements
  class Repo
    def initialize
      @announcements = []
    end

    def find(id)
      @announcements.select { |a| a.has_id(id) }.first || Announcement.draft(id)
    end

    def save(announcement)
      @announcements.reject! { |a| a.has_id(announcement.id) }
      @announcements << announcement
    end
  end
  private_constant :Repo
end
