class UsersController < ApplicationController

  def sign_in
    render json: { accessToken: "access-token" }
  end
end
