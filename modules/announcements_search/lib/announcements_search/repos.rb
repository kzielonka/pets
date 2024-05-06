require "active_record"

class AnnouncementsSearch
  module Repos
    def self.build(obj)
      case obj
      when :in_memory then InMemoryRepo.new
      when :active_record then ActiveRecordRepo.new
      else raise RuntimeError.new("invalid repo #{obj.inspect}")
      end
    end

    class InMemoryRepo
      def initialize
        reset!
      end

      def save(announcement)
        delete(announcement.id)
        @announcements << announcement
      end

      def search(location = Announcements::Location.zero)
        @announcements.sort_by { |a| a.approximate_distance_to(location) }
      end

      def delete(id)
        @announcements.reject! { |a| a.id == id }
      end

      def reset!
        @announcements = []
      end
    end
    private_constant :InMemoryRepo

    class ActiveRecordRepo

      def save(announcement)
        Record.create(
          id: announcement.id,
          title: announcement.title,
          content: announcement.content,
          location: Location.new(announcement.location).point
        )
      rescue ActiveRecord::RecordNotUnique
        Record.where(id: announcement.id).update_all(
          title: announcement.title,
          content: announcement.content,
          location: Location.new(announcement.location).point
        )
      end

      def delete(id)
        Record.where(id: id).delete_all
      end

      def search(location = Announcements::Location.zero)
        Record.order(OrderByLocationSql.from(location).sql).map do |record|
          Announcement.blank(record.id)
            .with_title(record.title)
            .with_content(record.content)
            .with_location(Announcements::Location.new(record.location.y, record.location.x))
        end
      end

      class Record < ActiveRecord::Base
        self.table_name = "public_announcements"
      end
      private_constant :Record
      
      class Location
        def initialize(location)
          @location = location
        end

        def point
          ActiveRecord::Point.new(@location.longitude, @location.latitude)
        end
      end
      private_constant :Location

      class OrderByLocationSql
        include ActiveRecord::Sanitization::ClassMethods

        def initialize(latitude, longitude)
          @latitude = latitude
          @longitude = longitude
        end

        def self.from(location)
          new(location.latitude, location.longitude)
        end

        def sql
          Arel.sql("(location <@> point(#{Float(@longitude)}, #{Float(@latitude)}))")
        end
      end
      private_constant :OrderByLocationSql
    end
    private_constant :ActiveRecordRepo
  end
  private_constant :Repos
end
