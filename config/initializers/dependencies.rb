require "auth"
require "announcements"

if Rails.env.test?
  Rails.application.config.auth = Auth.new("secret", :in_memory, proc { Time.now }, :fake_crypt)
else
  Rails.application.config.auth = Auth.new("secret", :active_record)
end

if Rails.env.test?
  Rails.application.config.announcements = Announcements.new(:in_memory)
else 
  Rails.application.config.announcements = Announcements.new(:active_record)
end
