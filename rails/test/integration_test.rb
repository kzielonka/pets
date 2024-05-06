require "test_helper"

class IntegrationTest < ActionDispatch::IntegrationTest

  def sign_in_random_user
    email = "test#{Random.new.rand}@example.com" 
    password = "PAssword1234$"
    sign_up(email, password)
    sign_in(email, password)
  end

  def sign_up(email, password)
    post "/sign_up", params: { email: email, password: password }
  end
  
  def sign_in(email, password)
    post "/sign_in", params: { email: email, password: password }
    access_token = JSON.parse(response.body)["accessToken"]
    user(access_token)
  end

  def user(access_token)
    UserContext.new(self, access_token)
  end

  class UserContext
    def initialize(test, access_token)
      @test = test
      @access_token = String(access_token).dup.freeze
    end

    def get(path, **args) 
      new_args = args.merge(headers: { "AUTHORIZATION" => "Bearer #{@access_token}" }
        .merge(args.fetch(:headers, {})))
      @test.get(path, **new_args)
      @test.response
    end

    def post(path, **args) 
      new_args = args.merge(headers: { "AUTHORIZATION" => "Bearer #{@access_token}" }
        .merge(args.fetch(:headers, {})))
      @test.post(path, **new_args)
      @test.response
    end

    def patch(path, **args) 
      new_args = args.merge(headers: { "AUTHORIZATION" => "Bearer #{@access_token}" }
        .merge(args.fetch(:headers, {})))
      @test.patch(path, **new_args)
      @test.response
    end

    def publish_announcement(title, content)
      response = post "/users/me/announcements"
      id = JSON.parse(response.body)["id"]
      
      patch "/users/me/announcements/#{id}", params: { title: title, content: content }

      post "/users/me/announcements/#{id}/publish"

      id
    end
  end
end
