class Announcements
  module Users
    SYSTEM_USER = Object.new.tap do |o|
      def o.system?
        true
      end

      def o.id
        "system"
      end

      def o.inspect
        "Announcements::SYSTEM_USER"
      end
    end

    class RegularUser
      def initialize(id)
        @id = String(id).dup.freeze
      end

      def system?
        false
      end

      attr_reader :id
    end
  end
end
