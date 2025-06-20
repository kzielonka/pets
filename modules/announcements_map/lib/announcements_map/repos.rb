require "active_record"

class AnnouncementsMap
  module Repos 
    def self.build(obj)
      case obj
      when :in_memory then InMemoryRepo.new
      else raise RuntimeError.new("invalid repo #{obj.inspect}")
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
    end
  end
end
