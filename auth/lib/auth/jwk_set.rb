class Auth
  class JwkSet
    def initialize(set)
      @set = JWT::JWK::Set.new(set)
    end

    def current 
      @set.first
    end
  end
end
