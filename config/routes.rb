Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  post "/sign_up" => "users#sign_up"
  post "/sign_in" => "users#sign_in"

  post "/users/:user_id/announcements" => "announcements#create"
  post "/users/:user_id/announcements/:id/publish" => "announcements#publish"
  post "/users/:user_id/announcements/:id/unpublish" => "announcements#unpublish"
  patch "/users/:user_id/announcements/:id" => "announcements#update"
  get "/users/:user_id/announcements" => "announcements#index"
  get "/users/:user_id/announcements/:id" => "announcements#show"

  get "/announcements" => "public_announcements#index"

  # Defines the root path route ("/")
  # root "posts#index"
end
