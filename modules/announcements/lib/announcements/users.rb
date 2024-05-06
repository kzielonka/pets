class Announcements
  module Users
    def self.build(user)
      case user
      when SYSTEM_USER, :system then SYSTEM_USER 
      when RegularUser then user
      when String then RegularUser.new(user)
      else raise ArgumentError.new("can convert #{user.inspect} to Announcements user")
      end
    end

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

      def ==(other)
        other.is_a?(RegularUser) && other.id == @id
      end
    end
  end
end
