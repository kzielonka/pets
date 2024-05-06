class AnnouncementsController < ApplicationController

  def create
    result = announcements.add_new_draft(user_id)
    render json: { id: result.id }
  end

  def update
    announcements.update_title(user_id, id, params[:title]) if params[:title]
    announcements.update_content(user_id, id, params[:content]) if params[:content]
    announcements.update_location(user_id, id, location) if params[:location]
    head :ok
  rescue Announcements::Errors::AuthorizationError
    head 403
  rescue Announcements::Errors::CanNotEditPublishedAnnouncementError 
    render status: 400, json: { error: "can-not-edit-published-announcement" }
  end

  def show
    result = announcements.fetch_private(user_id, id)
    if result.not_found?
      head 404
      return
    end
    render json: {
      draft: result.draft?,
      title: result.title,
      content: result.content,
      location: {
        latitude: result.location.latitude,
        longitude: result.location.longitude
      }
    }
  end

  def index
    list = announcements.fetch_all_for(user_id)
    render json: list.sort_by { |a, b| a.title }.map { |a|
      {
        "id" => a.id,
        "draft" => a.draft?,
        "title" => a.title,
        "content" => a.content,
      }
    }
  end

  def publish
    announcements.publish(user_id, id)
    head :ok
  rescue Announcements::Errors::AuthorizationError
    head 403
  rescue  Announcements::Errors::UnfinishedDraftError
    head 400
  end

  def unpublish
    announcements.unpublish(user_id, id)
    head :ok
  rescue Announcements::Errors::AuthorizationError
    head 403
  rescue  Announcements::Errors::UnfinishedDraftError
    head 400
  end

  private

  def id
    String(params[:id])
  end

  def user_id
    String(request.headers["HTTP_AUTHORIZATION"])
  end

  def location
    {
      latitude: params[:location][:latitude].to_f,
      longitude: params[:location][:longitude].to_f
    }
  end

  def announcements
    Rails.application.config.announcements
  end
end
