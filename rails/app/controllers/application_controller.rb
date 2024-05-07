class ApplicationController < ActionController::Base
  # API is stateless and don't need this:
  # https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  protect_from_forgery with: :null_session
end
