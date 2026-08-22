# frozen_string_literal: true

require 'auth'
require 'announcements'
require 'announcements_search'
require 'announcements_map'
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

Rails.application.config.announcements_search = if Rails.env.test?
                                                   AnnouncementsSearch.new(:in_memory)
                                                 else
                                                   AnnouncementsSearch.new(:active_record)
                                                 end
Rails.application.config.announcements_search.subscribe(events_bus)

Rails.application.config.announcements_map = if Rails.env.test?
                                                AnnouncementsMap.new(:in_memory)
                                              else
                                                AnnouncementsMap.new(:active_record)
                                              end
Rails.application.config.announcements_map.subscribe(events_bus)
