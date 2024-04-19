require "minitest/autorun"
require "auth"

class Auth
  class TestPassword < Minitest::Test

    def test_password_check
      password1 = Password.from("password")
      password2 = Password.from("password")
      password3 = Password.from("password2")

      assert password1.encrypted.same?(password1)
      assert password1.encrypted.same?(password2)
      assert password3.encrypted.same?(password3)
      assert !password3.encrypted.same?(password1)
    end
  end
end
