# frozen_string_literal: true

class AnnouncementsMap
  class SearchResults
    class PinBase
      def initialize(latitude, longitude)
        @latitude = Types::Latitude(latitude)
        @longitude = Types::Longitude(longitude)
      end

      attr_reader :latitude, :longitude
    end
    private_constant :PinBase

    class SinglePin < PinBase
      def initialize(announcement_id, latitude, longitude)
        super(latitude, longitude)
        @announcement_id = String(announcement_id)
      end

      def type
        :single_pin
      end

      attr_reader :announcement_id
    end

    class GroupPin < PinBase
      def initialize(number_of_pins, latitude, longitude)
        super(latitude, longitude)
        @number_of_pins = Integer(number_of_pins)
      end

      def type
        :group_pin
      end

      attr_reader :number_of_pins
    end
  end
  private_constant :SearchResults
end
