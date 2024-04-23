require "auth"
require "announcements"

Rails.application.config.auth = Auth.new("secret")

if Rails.env.test?
  Rails.application.config.announcements = Announcements.new
else 
  Rails.application.config.announcements = Announcements.new(:active_record)
end
