class Auth
  module Errors
    DuplicatedEmailError = Class.new(RuntimeError)
    ValidationError = Class.new(RuntimeError)
  end
end
