require "auth/errors"
require "auth/repos"
require "auth/credentials"
require "auth/serialized_credentials"
require "auth/user_id"
require "auth/email"
require "auth/password"
require "auth/encrypted_password"
require "auth/password_factory"
require "auth/access_token"
require "auth/jwt_access_token"
require "auth/jwk_set"
require "jwt"

# The Auth class serves as the public facade for the Authentication module.
# It encapsulates all user registration, credentials hashing, and stateless JWT token authentication.
class Auth 
  # Initializes the Auth facade.
  #
  # @param hmac_secret [String] secret key used to sign and verify JWT access tokens.
  # @param repo [Symbol] the database repository strategy, either :in_memory or :active_record.
  # @param time_now_proc [Proc] proc returning the current time (used for token validation).
  # @param password_encryption [Symbol] hashing strategy to use, either :bcrypt or :fake_crypt.
  def initialize(hmac_secret, repo = :in_memory, time_now_proc = proc { Time.now }, password_encryption = :bcrypt)
    @secret = String(hmac_secret).dup.freeze
    @time_now_proc = time_now_proc
    @password_factory = PasswordFactory.build(password_encryption)
    @repo = Repos.build(repo, @password_factory)
  end

  # Registers a new user with the given email and password.
  #
  # @param email [String] raw email address.
  # @param password [String] raw password.
  # @raise [Auth::Errors::DuplicatedEmailError] if the email is already registered.
  # @raise [Auth::Errors::ValidationError] if validation on email format or password strength fails.
  # @return [nil]
  def sign_up(email, password)
    email = Email.from(email)
    password = @password_factory.raw_password(password).encrypted 
    credentials = Credentials.random(@password_factory)
      .for_email(email)
      .with_password(password)
    if @repo.exists_email?(email)
      raise Errors::DuplicatedEmailError.new
    end
    @repo.save(credentials)
    nil
    # TODO: add retry on index error from DB 
  rescue Email::ValidationError => err
    raise Errors::ValidationError.new(err.message)
  rescue Password::ValidationError => err
    raise Errors::ValidationError.new(err.message)
  end

  # Authenticates a user and generates a JWT access token if successful.
  #
  # @param email [String] raw email address.
  # @param password [String] raw password.
  # @return [SignInResult] DTO containing authenticated? (Boolean) and access_token (String).
  def sign_in(email, password)
    email = Email.from(email)
    password = @password_factory.raw_password(password)
    credentials = @repo.find_by_email(email)
    jwt = AccessToken
      .blank
      .for_user(credentials.user_id)
      .issued_at(@time_now_proc.call)
      .jwt(@secret)
    SignInResult.new(credentials.matches_password?(password), jwt.to_s)
  rescue Email::ValidationError
    SignInResult.new(false, "")
  rescue Password::ValidationError
    SignInResult.new(false, "")
  end

  # Validates the access token (JWT) and returns the associated user ID.
  #
  # @param access_token [String] raw JWT access token from the Authorization header.
  # @return [AuthenticationResult] DTO containing success? (Boolean) and user_id (UserId).
  def authenticate(access_token)
    access_token = JwtAccessToken.new(access_token)
    unless access_token.valid?(@secret, @time_now_proc.call)
      return AuthenticationResult.new(false, UserId.from(""))
    end
    AuthenticationResult.new(true, access_token.user_id)
  end

  # Wipes all credentials stored in the repository. Typically used between tests.
  #
  # @return [void]
  def reset!
    @repo.reset!
  end

  SignInResult = Struct.new(:authenticated?, :access_token)
  private_constant :SignInResult

  SignUpResult = Struct.new(:signed_up?, :errors) do
    def self.success
      new(true, [])
    end

    def self.error(*errors)
      new(false, Array(errors))
    end

    def duplicated_error?
      @errors.include(:duplciated_email)
    end
  end
  private_constant :SignUpResult

  AuthenticationResult = Struct.new(:success?, :user_id)
  private_constant :AuthenticationResult
end
