# frozen_string_literal: true

require 'active_record'

class AnnouncementsMap
  module Repos
    def self.build(obj)
      case obj
      when :in_memory then InMemoryRepo.new
      when :active_record then ActiveRecordRepo.new
      else raise "invalid repo #{obj.inspect}"
      end
    end

    class InMemoryRepo
      def initialize
        @pins = []
      end

      def save(pin)
        @pins.reject! { |p| p.id == pin.id }
        @pins << pin
      end

      def search(bounding_box)
        bounding_box = Types::BoundingBox(bounding_box)
        @pins.select { |pin| bounding_box.contains?(pin.latitude, pin.longitude) }
      end

      def delete(id)
        id = String(id)
        @pins.reject! { |p| p.id == id }
      end

      def reset!
        @pins = []
      end
    end
    private_constant :InMemoryRepo

    class ActiveRecordRepo
      def save(pin)
        record = Record.find_or_initialize_by(id: pin.id)
        record.location = Location.new(pin).point
        record.title ||= ''
        record.content ||= ''
        record.save
      end

      def search(bounding_box)
        bounding_box = Types::BoundingBox(bounding_box)
        Record.where(
          'location[1] <= ? AND location[1] >= ? AND location[0] <= ? AND location[0] >= ?',
          bounding_box.top.to_f,
          bounding_box.bottom.to_f,
          bounding_box.right.to_f,
          bounding_box.left.to_f
        ).map do |record|
          Pin.parse(record.id, record.location.y, record.location.x)
        end
      end

      def delete(id)
        Record.where(id: id).delete_all
      end

      def reset!
        Record.delete_all
      end

      class Record < ActiveRecord::Base
        self.table_name = 'public_announcements'
      end
      private_constant :Record

      class Location
        def initialize(pin)
          @pin = pin
        end

        def point
          ActiveRecord::Point.new(@pin.longitude.to_f, @pin.latitude.to_f)
        end
      end
      private_constant :Location
    end
    private_constant :ActiveRecordRepo
  end
end
