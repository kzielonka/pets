class UsersController < ApplicationController

  def sign_up
    head 200
  end

  def sign_in
    render json: { accessToken: "access-token-#{email}" }
  end

  private

  def email
    String(params[:email])
  end
end
