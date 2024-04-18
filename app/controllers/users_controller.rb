class UsersController < ApplicationController

  def sign_up
    auth.sign_up(email, password)
    head 200
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
