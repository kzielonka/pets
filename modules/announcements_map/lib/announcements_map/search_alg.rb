# frozen_string_literal: true

class AnnouncementsMap
  class SearchAlg
    def initialize(bb, _pins)
      @bb = Types.BoundingBox(bb)
      @pins = Array(list).map(Types.Pin)
    end

    def run
      []
    end

    class PinsList
      def initialize(list)
        @list = Array(list).map(Types.Pin)
      end

      def best_group_candidate(_distance)
        @list.each do |pin|
        end
      end

      def pins_in_range(pin, distance)
        Types.Pin(pin)
        @list.count { |pin| pin.distance_to(pin) <= distance }
      end
    end
  end
end
