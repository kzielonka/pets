class PublicAnnouncementsController < ApplicationController

  def index
    announcements = announcements_search.search(location).map { |a| AnnouncementJson.new(a) }
    render status: 200, json: { announcements: announcements.map { |a| a.json } }
  rescue SearchLocation::ValidationError
    render status: 400, json: { error: "location-validation-error" }
  end

  private

  def location
    SearchLocation.new(params).location
  end

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

  class SearchLocation
    def initialize(params)
      @params = params
    end

    def location
      Announcements::Location.new(latitude, longitude)
    end

    private

    def latitude
      raise ValidationError.new("invalid latitude") unless number? @params[:latitude]
      @params[:latitude].to_f
    end

    def longitude
      raise ValidationError.new("invalid longitude") unless number? @params[:longitude]
      @params[:longitude].to_f
    end
    
    def number?(number)
      /^\d+(\.\d+)?$/.match number
    end

    ValidationError = Class.new(RuntimeError)
  end
  private_constant :SearchLocation
end

