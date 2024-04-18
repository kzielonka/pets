class AnnouncementsController < ApplicationController

  def create
    result = announcements.add_new_draft("me")
    render json: { id: result.id }
  end

  def update
    announcements.update_title(user_id, id, params[:title]) if params[:title]
    announcements.update_content(user_id, id, params[:content]) if params[:content]
    head :ok
  end

  def show
    result = announcements.fetch_private(user_id, id)
    render json: {
      draft: result.draft?,
      title: result.title,
      content: result.content
    }
  end

  def publish
    announcements.publish(user_id, id)
    head :ok
  end

  private

  def id
    String(params[:id])
  end

  def user_id
    String(params[:user_id])
  end

  def announcements
    Rails.application.config.announcements
  end
end
