require "securerandom" 

require "announcements/errors"
require "announcements/users"
require "announcements/repo"
require "announcements/announcement"

class Announcements
  def initialize
    @repo = Repo.new
  end

  def add_new_draft(user)
    announcement = Announcement.draft.assign_owner(user.id)
    @repo.save(announcement)
    NewDraft.new(announcement.id)
  end

  def update_title(user, id, title)
    user = Users.build(user)
    @repo.find(id).change_title(user, title)
  end

  def update_content(user, id, content)
    user = Users.build(user)
    @repo.find(id).change_content(user, content)
  end

  def publish(user, id)
    user = Users.build(user)
    @repo.find(id).publish(user)
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
end
