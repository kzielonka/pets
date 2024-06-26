require "auth"
require "announcements"
require "announcements_search"
require "events_bus"

events_bus = EventsBus.new

if Rails.env.test?
  Rails.application.config.auth = Auth.new("secret", :in_memory, proc { Time.now }, :fake_crypt)
else
  Rails.application.config.auth = Auth.new("secret", :active_record)
end

if Rails.env.test?
  Rails.application.config.announcements = Announcements.new(events_bus, :in_memory)
else 
  Rails.application.config.announcements = Announcements.new(events_bus, :active_record)
end

Rails.application.config.announcements_search = AnnouncementsSearch.new
Rails.application.config.announcements_search.subscribe(events_bus)
