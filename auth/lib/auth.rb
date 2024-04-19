require "auth/repo"
require "auth/credentials"
require "auth/user_id"
require "auth/email"
require "auth/password"
require "auth/access_token"
require "auth/jwt_access_token"
require "auth/jwk_set"
require "jwt"

class Auth 
  def initialize(hmac_secret, time_now_proc = proc { Time.now })
    @secret = String(hmac_secret).dup.freeze
    @time_now_proc = time_now_proc
    @repo = Repo.new
  end

  def sign_up(email, password)
    email = Email.from(email)
    password = Password.from(password)
    credentials = Credentials.random_user_id(email, password)
    @repo.save(credentials)
    nil
  end

  def sign_in(email, password)
    email = Email.from(email)
    password = Password.from(password)
    credentials = @repo.find_by_email(email)
    payload = { sub: credentials.user_id.to_s }
    jwt = AccessToken
      .blank
      .for_user(credentials.user_id)
      .issued_at(@time_now_proc.call)
      .jwt(@secret)
    SignInResult.new(credentials.matches_password?(password), jwt.to_s)
  end

  def authenticate(access_token)
    access_token = JwtAccessToken.new(access_token)
    unless access_token.valid?(@secret, @time_now_proc.call)
      return AuthenticationResult.new(false, UserId.from(""))
    end
    AuthenticationResult.new(true, access_token.user_id)
  end

  SignInResult = Struct.new(:authenticated?, :access_token)
  private_constant :SignInResult

  AuthenticationResult = Struct.new(:success?, :user_id)
  private_constant :AuthenticationResult
end
