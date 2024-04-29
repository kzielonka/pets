require "active_record" 

class Auth 
  module Repos
    UserIdTakenError = Class.new(RuntimeError)
    EmailTakenError = Class.new(RuntimeError)
    
    def self.build(obj, password_factory)
      case obj
      when :in_memory then InMemoryRepo.new(password_factory)
      when :active_record then ActiveRecordRepo.new(password_factory)
      else raise RuntimeError.new("invalid repo #{obj.inspect}")
      end
    end

    class InMemoryRepo
      def initialize(password_factory)
        @password_factory = password_factory
        reset!
      end

      def save(credentials)
        raise UserIdTakenError.new if exists_user_id?(credentials.serialize.user_id)
        raise EmailTakenError.new if exists_email?(credentials.serialize.email)
        @list << credentials
      end

      def exists_email?(email)
        @list.any? { |c| c.for_email?(email) }
      end

      def find_by_email(email)
        @list.select { |c| c.for_email?(email) }.first || Credentials.random(@password_factory).for_email(email)
      end

      def find_by_user_id(user_id)
        @list.select { |c| c.for_user?(user_id) }.first || Credentials.random(@password_factory).for_user(user_id)
      end

      def reset!
        @list = []
      end

      private 

      def exists_user_id?(user)
        @list.any? { |c| c.for_user?(user) }
      end
    end
    private_constant :InMemoryRepo

    class ActiveRecordRepo
      def initialize(password_factory)
        @password_factory = password_factory
      end
      
      def save(credentials)
        serialized_credentials = credentials.serialize
        Record.create(
          user_id: serialized_credentials.user_id.to_s,
          email: serialized_credentials.email.to_s,
          password: serialized_credentials.password.to_s
        )
      rescue ActiveRecord::RecordNotUnique => err
        raise UserIdTakenError.new if err.message.include?("Key (user_id)")
        raise EmailTakenError.new if err.message.include?("Key (email)")
        raise err
      end

      def exists_email?(email)
        Record.where(email: email.to_s).count > 0
      end

      def find_by_email(email)
        email = Email.from(email)
        Record.where(email: email.to_s).map do |record|
          password = @password_factory.encrypted_password(record.password)
          Credentials.new(record.user_id, record.email, password)
        end.first || Credentials.random(@password_factory).for_email(email)
      end

      def find_by_user_id(user_id)
        user_id = UserId.from(user_id)
        Record.where(user_id: user_id.to_s).map do |record|
          password = @password_factory.encrypted_password(record.password)
          Credentials.new(record.user_id, record.email, password)
        end.first || Credentials.random(@password_factory).for_user(user_id)
      end

      class Record < ActiveRecord::Base
        self.table_name = "credentials"
      end
    end
    private_constant :ActiveRecordRepo
  end
  private_constant :Repos
end
