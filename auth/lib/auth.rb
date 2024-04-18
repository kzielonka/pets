require "auth/repo"
require "auth/credentials"
require "auth/user_id"
require "auth/email"
require "auth/password"

class Auth 
  def initialize
    @repo = Repo.new
  end

  def sign_up(email, password)
    email = Email.from(email)
    password = Password.from(password)
    credentials = Credentials.random_user_id(email, password)
    @repo.save(credentials)
  end

  def sign_in(email, password)
    email = Email.from(email)
    password = Password.from(password)
    credentials = @repo.find_by_email(email)
    SignInResult.new(credentials.matches_password?(password), email.to_s)
  end

  SignInResult = Struct.new(:authenticated?, :access_token)
  private_constant :SignInResult
end
