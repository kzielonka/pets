require "active_record"

class Announcements
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
        @announcements = []
      end

      def find(id)
        @announcements.select { |a| a.has_id(id) }.first || Announcement.draft(id)
      end

      def find_by_user(user)
        @announcements.select { |a| a.belongs_to?(user) }
      end

      def save(announcement)
        @announcements.reject! { |a| a.has_id(announcement.id) }
        @announcements << announcement
      end
    end
    private_constant :InMemoryRepo

    class ActiveRecordRepo

      def save(announcement)
        serialized_announcement = announcement.serialize
        Record.create(
          id: serialized_announcement.id,
          owner_id: serialized_announcement.owner_id,
          draft: serialized_announcement.draft,
          title: serialized_announcement.title,
          content: serialized_announcement.content
        )
      rescue ActiveRecord::RecordNotUnique
        Record
          .where(id: serialized_announcement.id)
          .update_all(
            owner_id: serialized_announcement.owner_id,
            draft: serialized_announcement.draft,
            title: serialized_announcement.title,
            content: serialized_announcement.content
          )
      end

      def find(id)
        record = Record.where(id: String(id)).first
        SerializedAnnouncement.new(record.id, record.owner_id, record.draft, record.title, record.content).deserialize
      end

      def find_by_user(user)
        user = Users.build(user)
        Record.where(owner_id: user.id).map do |record|
          SerializedAnnouncement.new(record.id, record.owner_id, record.draft, record.title, record.content)
            .deserialize
        end
      end

      class Record < ActiveRecord::Base
        self.table_name = "announcements"
      end
      private_constant :Record
    end
    private_constant :ActiveRecordRepo
  end
  private_constant :Repos
end
