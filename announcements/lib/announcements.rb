require "securerandom" 

require "announcements/errors"
require "announcements/users"
require "announcements/repo"
require "announcements/announcement"
require "announcements/serialized_announcement"

class Announcements
  def initialize(repo = :in_memory)
    @repo = Repos.build(repo)
  end

  def add_new_draft(user)
    user = Users.build(user)
    announcement = Announcement.draft_with_random_id.assign_owner(user.id)
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
    if announcement.public?
      FetchResult.new(false, announcement.draft?, announcement.title, announcement.content)
    else 
      FetchResult.new(true, false, "", "")
    end
  end

  def fetch_private(user, id)
    user = Users.build(user)
    announcement = @repo.find(id)
    if announcement.can_be_viewed_by?(user)
      FetchResult.new(false, announcement.draft?, announcement.title, announcement.content)
    else
      FetchResult.new(true, false, "", "")
    end
  end

  def fetch_all_for(user)
    user = Users.build(user)
    @repo.find_by_user(user).map do |announcement|
      AnnouncementData.new(announcement.id, announcement.draft?, announcement.title, announcement.content)
    end
  end

  NewDraft = Struct.new(:id)
  private_constant :NewDraft

  FetchResult = Struct.new(:not_found?, :draft?, :title, :content)
  private_constant :FetchResult

  AnnouncementData = Struct.new(:id, :draft?, :title, :content)
  private_constant :AnnouncementData
end
