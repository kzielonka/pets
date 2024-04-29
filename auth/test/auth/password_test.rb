require "minitest/autorun"
require "auth"

class Auth
  class TestPassword < Minitest::Test

    def test_password_check_with_fake_encryption
      password_factory = PasswordFactory.build(:fake)

      password1 = password_factory.raw_password("password")
      password2 = password_factory.raw_password("password")
      password3 = password_factory.raw_password("password2")

      assert password1.encrypted.same?(password1)
      assert password1.encrypted.same?(password2)
      assert password3.encrypted.same?(password3)
      assert !password3.encrypted.same?(password1)

      assert password1.encrypted.to_s != password2.encrypted.to_s
      assert password1.encrypted.to_s != password3.encrypted.to_s
    end

    def test_password_check_with_bcrypt_encryption
      password_factory = PasswordFactory.build(:bcrypt)

      password1 = password_factory.raw_password("password")
      password2 = password_factory.raw_password("password")
      password3 = password_factory.raw_password("password2")

      
      assert password1.encrypted.same?(password1)
      assert password1.encrypted.same?(password2)
      assert password3.encrypted.same?(password3)
      assert !password3.encrypted.same?(password1)

      assert password1.encrypted.to_s != password2.encrypted.to_s
      assert password1.encrypted.to_s != password3.encrypted.to_s
    end
  end
end
