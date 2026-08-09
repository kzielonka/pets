# frozen_string_literal: true

require 'auth'
require 'announcements'
require 'announcements_search'
require 'events_bus'

events_bus = EventsBus.new

Rails.application.config.auth = if Rails.env.test?
                                  Auth.new('secret', :in_memory, proc { Time.now }, :fake_crypt)
                                else
                                  Auth.new('secret', :active_record)
                                end

Rails.application.config.announcements = if Rails.env.test?
                                           Announcements.new(events_bus, :in_memory)
                                         else
                                           Announcements.new(events_bus, :active_record)
                                         end

Rails.application.config.announcements_search = AnnouncementsSearch.new
Rails.application.config.announcements_search.subscribe(events_bus)
