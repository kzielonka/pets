require "auth"
require "announcements"

if Rails.env.test?
  Rails.application.config.auth = Auth.new("secret")
else
  Rails.application.config.auth = Auth.new("secret", :active_record)
end

if Rails.env.test?
  Rails.application.config.announcements = Announcements.new
else 
  Rails.application.config.announcements = Announcements.new(:active_record)
end
