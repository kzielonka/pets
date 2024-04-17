require "securerandom" 

require "announcements/repo"
require "announcements/announcement"

class Announcements
  def initialize
    @repo = Repo.new
  end

  def add_new_draft(creator_id)
    announcement = Announcement.draft.assign_owner(creator_id)
    @repo.save(announcement)
    NewDraft.new(announcement.id)
  end

  def update_title(user, id, title)
     @repo.find(id).change_title(user, title)
  end

  def update_content(user, id, content)
     @repo.find(id).change_content(user, content)
  end

  def publish(user, id)
    @repo.find(id).publish
  end

  def fetch_public(id)
    announcement = @repo.find(id)
    if announcement && announcement.public?
      FetchResult.new(false, announcement.title, announcement.content)
    else 
      FetchResult.new(true, "", "")
    end
  end

  NewDraft = Struct.new(:id)
  private_constant :NewDraft

  FetchResult = Struct.new(:not_found?, :title, :content)
  private_constant :FetchResult

  PublicAnnouncement = Struct.new(:public_id, :title, :content)
  private_constant :PublicAnnouncement

  SYSTEM_USER = Object.new.tap do |o|
    def system?
      true
    end
  end

  class RegularUser
    def initialize(user_id)
      @user_id = String(user_id).dup.freeze
    end

    def system?
      false
    end
  end
end
