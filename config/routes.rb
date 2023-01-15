# frozen_string_literal: true

class Stringer < Sinatra::Base
  def self.match(path, to:, via:)
    controller_name, action_name = to.split("#")
    controller_klass = "#{controller_name.camelize}Controller".constantize
    route(via.to_s.upcase, path) do
      # Make sure that our parsed URL params are where Rack (and
      # ActionDispatch) expect them
      app = controller_klass.action(action_name)
      app.call(request.env.merge("rack.request.query_hash" => params))
    end
  end

  match("/debug", to: "debug#index", via: :get)
  match("/heroku", to: "debug#heroku", via: :get)
  match("/feeds", to: "feeds#index", via: :get)
  match("/feeds/:id/edit", to: "feeds#edit", via: :get)
  match("/feeds/:id", to: "feeds#update", via: :put)
  match("/feeds/:id", to: "feeds#destroy", via: :delete)
  match("/feeds/new", to: "feeds#new", via: :get)
  match("/feeds", to: "feeds#create", via: :post)
  match("/feeds/export", to: "exports#index", via: :get)
  match("/feeds/import", to: "imports#new", via: :get)
  match("/feeds/import", to: "imports#create", via: :post)
  match("/login", to: "sessions#new", via: :get)
  match("/login", to: "sessions#create", via: :post)
  match("/logout", to: "sessions#destroy", via: :get)
  match("/setup/password", to: "passwords#new", via: :get)
  match("/setup/password", to: "passwords#create", via: :post)
  match("/setup/tutorial", to: "tutorials#index", via: :get)
  match("/stories/:id", to: "stories#update", via: :put)
  match("/stories/mark_all_as_read", to: "stories#mark_all_as_read", via: :post)
end
