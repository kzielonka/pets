class Auth
  module RepoContractTests
    def test_saves_credentials
      user_id = UserId.random
      email = Email.from("test@example.com")
      password = Password.random 
      credentials = Credentials.new(user_id, email, password)
      @repo.save(credentials)
      found_credentials = @repo.find_by_user_id(user_id)
      assert found_credentials.for_user?(user_id)
      assert found_credentials.for_email?(email)
      assert found_credentials.matches_password?(password)
    end

    def test_finds_credentials_by_email
      user_1_id = UserId.random
      email_1 = Email.random
      password_1 = Password.random 
      credentials_1 = Credentials.new(user_1_id, email_1, password_1)

      user_2_id = UserId.random
      email_2 = Email.random
      password_2 = Password.random 
      credentials_2 = Credentials.new(user_2_id, email_2, password_2)

      @repo.save(credentials_1)
      @repo.save(credentials_2)

      found_credentials = @repo.find_by_email(email_1)
      assert found_credentials.for_user?(user_1_id)
      assert found_credentials.for_email?(email_1)
      assert found_credentials.matches_password?(password_1)

      found_credentials = @repo.find_by_email(email_2)
      assert found_credentials.for_user?(user_2_id)
      assert found_credentials.for_email?(email_2)
      assert found_credentials.matches_password?(password_2)
    end

    def test_checking_email_existance
      user_1_id = UserId.random
      email_1 = Email.random
      password_1 = Password.random 
      credentials_1 = Credentials.new(user_1_id, email_1, password_1)

      user_2_id = UserId.random
      email_2 = Email.random
      password_2 = Password.random 
      credentials_2 = Credentials.new(user_2_id, email_2, password_2)

      @repo.save(credentials_1)
      @repo.save(credentials_2)

      assert @repo.exists_email?(email_1)
      assert @repo.exists_email?(email_1)
      assert !@repo.exists_email?(Email.random)
    end

    def test_returns_random_credentials_trying_to_find_not_existing_one_by_email
      email = Email.random
      found_credentials = @repo.find_by_email(email)
      assert found_credentials.for_email?(email)
    end

    def test_returns_random_credentials_trying_to_find_not_existing_one_by_user_id
      user_id = UserId.random
      found_credentials = @repo.find_by_user_id(user_id)
      assert found_credentials.for_user?(user_id)
    end

    def test_raises_error_trying_to_save_credentials_with_duplicated_email
      email = Email.random

      user_1_id = UserId.random
      password_1 = Password.random 
      credentials_1 = Credentials.new(user_1_id, email, password_1)

      user_2_id = UserId.random
      password_2 = Password.random 
      credentials_2 = Credentials.new(user_2_id, email, password_2)

      @repo.save(credentials_1)
      assert_raises(Repos::EmailTakenError) { @repo.save(credentials_2) }
    end

    def test_raises_error_trying_to_save_credentials_with_duplicated_user_id
      user_id = UserId.random

      email_1 = Email.random
      password_1 = Password.random 
      credentials_1 = Credentials.new(user_id, email_1, password_1)

      email_2 = Email.random
      password_2 = Password.random 
      credentials_2 = Credentials.new(user_id, email_2, password_2)

      @repo.save(credentials_1)
      assert_raises(Repos::UserIdTakenError) { @repo.save(credentials_2) }
    end
  end

  class TestInMemoryRepo < Minitest::Test
    def setup
      @repo = Repos.build(:in_memory)
    end

    include RepoContractTests
  end

  class ActiveRecordRepo < Minitest::Test
    def setup
      test_db_url = String(ENV["TEST_DATABASE_URL"])
      raise "Please set TEST_DATABASE_URL env" if test_db_url == ""
      ActiveRecord::Base.establish_connection(
        adapter: "postgresql",
        url: test_db_url
      ) 
      ActiveRecord::Base.connection.execute("DELETE FROM credentials;")
      @repo = Repos.build(:active_record)
    end

    include RepoContractTests
  end
end
