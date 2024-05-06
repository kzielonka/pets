class UsersController < ApplicationController

  def sign_up
    auth.sign_up(email, password)
    head 200
  rescue Auth::Errors::DuplicatedEmailError
    render status: 400, json: { error: "duplicated-email" }
  rescue Auth::Errors::ValidationError => err
    render status: 400, json: { error: "validation-error", debugMessage: err.message }
  end

  def sign_in
    result = auth.sign_in(email, password)
    unless result.authenticated?
      head 401
      return
    end
    render json: { accessToken: result.access_token }
  end

  private

  def email
    String(params[:email])
  end

  def password 
    String(params[:password])
  end

  def auth
    Rails.application.config.auth 
  end
end
