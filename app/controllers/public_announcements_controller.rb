class PublicAnnouncementsController < ApplicationController

  def index
    announcements = announcements_search.search.map { |a| AnnouncementJson.new(a) }
    render status: 200, json: { announcements: announcements.map { |a| a.json } }
  end

  private

  def announcements_search
    Rails.application.config.announcements_search
  end

  class AnnouncementJson
    def initialize(announcement)
      @announcement = announcement
    end

    def json
      {
        id: @announcement.id,
        title: @announcement.title,
        content: @announcement.content,
        location: {
          latitude: @announcement.location.latitude,
          longitude: @announcement.location.longitude
        }
      }
    end
  end
  private_constant :AnnouncementJson
end

