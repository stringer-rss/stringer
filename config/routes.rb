# frozen_string_literal: true

Rails.application.routes.draw do
  resource :profile, only: [:edit, :update]
  resource :password, only: [:update]
  resource :api_key, only: [:update]

  match("/", to: "stories#index", via: :get)
  match("/fever", to: "fever#index", via: :get)
  match("/fever", to: "fever#update", via: :post)
  match("/archive", to: "stories#archived", via: :get)
  match("/debug", to: "debug#index", via: :get)
  match("/feed/:feed_id", to: "feeds#show", via: :get)
  match("/feeds", to: "feeds#create", via: :post)
  match("/feeds", to: "feeds#index", via: :get)
  match("/feeds/:id", to: "feeds#destroy", via: :delete)
  match("/feeds/:id", to: "feeds#update", via: :put)
  match("/feeds/:id/edit", to: "feeds#edit", via: :get)
  match("/feeds/export", to: "exports#index", via: :get)
  match("/feeds/import", to: "imports#create", via: :post)
  match("/feeds/import", to: "imports#new", via: :get)
  match("/feeds/new", to: "feeds#new", via: :get)
  match("/heroku", to: "debug#heroku", via: :get)
  match("/login", to: "sessions#create", via: :post)
  match("/login", to: "sessions#new", via: :get)
  match("/logout", to: "sessions#destroy", via: :get)
  match("/news", to: "stories#index", via: :get)
  match("/setup/password", to: "passwords#create", via: :post)
  match("/setup/password", to: "passwords#new", via: :get)
  match("/setup/tutorial", to: "tutorials#index", via: :get)
  match("/starred", to: "stories#starred", via: :get)
  match("/stories/:id", to: "stories#update", via: :put)
  match("/stories/mark_all_as_read", to: "stories#mark_all_as_read", via: :post)

  unless Rails.env.production?
    require_relative "../spec/javascript/test_controller"

    match("/test", to: "test#index", via: :get)
    match("/spec/*splat", to: "test#spec", via: :get)
    match("/vendor/js/*splat", to: "test#vendor", via: :get)
    match("/vendor/css/*splat", to: "test#vendor", via: :get)
  end
end
