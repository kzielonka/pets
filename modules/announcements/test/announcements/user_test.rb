require "minitest/autorun"
require "announcements"

class Announcements
  class TestUsers < Minitest::Test
    def test_system_user_build_from_symbol
      user = Users.build(:system)
      assert_equal Users::SYSTEM_USER, user 
    end

    def test_system_user_build_from_object
      user = Users.build(Users::SYSTEM_USER)
      assert_equal Users::SYSTEM_USER, user 
    end

    def test_regular_user_build_from_object
      user = Users.build(Users::RegularUser.new("user-id"))
      assert_equal Users::RegularUser.new("user-id"), user 
    end

    def test_regular_user_build_from_string
      user = Users.build("user-id")
      assert_equal Users::RegularUser.new("user-id"), user 
    end

    def test_regular_user_equality
      user1 = Users::RegularUser.new("user-id-1")
      user2 = Users::RegularUser.new("user-id-1")
      user3 = Users::RegularUser.new("user-id-2")
      assert user1 == user1
      assert user1 == user2
      assert user1 != user3
      assert user1 != Object.new
    end
  end
end
