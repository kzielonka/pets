class AnnouncementsSearch
  module Repos
    def self.build(obj)
      case obj
      when :in_memory then InMemoryRepo.new
      else raise RuntimeError.new("invalid repo #{obj.inspect}")
      end
    end

    class InMemoryRepo
      def initialize
        reset!
      end

      def save(announcement)
        @announcements << announcement
      end

      def search(location = Announcements::Location.zero)
        @announcements.sort_by { |a| a.approximate_distance_to(location) }
      end

      def reset!
        @announcements = []
      end
    end
  end
  private_constant :Repos
end
