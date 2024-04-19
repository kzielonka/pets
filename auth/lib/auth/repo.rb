class Auth 
  class Repo
    def initialize
      @list = []
    end

    def save(credentials)
      @list << credentials
    end

    def find_by_email(email)
      @list.select { |c| c.for_email?(email) }.first || Credentials.random(email)
    end

    def find_by_user_id(user_id)
      @list.select { |c| c.for_user?(user_id) }.first || Credentials.random(email)
    end
  end
  private_constant :Repo
end
