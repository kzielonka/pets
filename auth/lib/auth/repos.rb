class Auth 
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

      def save(credentials)
        @list << credentials
      end

      def exists_email?(email)
        @list.any? { |c| c.for_email?(email) }
      end

      def find_by_email(email)
        @list.select { |c| c.for_email?(email) }.first || Credentials.random(email)
      end

      def find_by_user_id(user_id)
        @list.select { |c| c.for_user?(user_id) }.first || Credentials.random(email)
      end

      def reset!
        @list = []
      end
    end
    private_constant :InMemoryRepo
  end
  private_constant :Repos
end
