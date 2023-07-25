# frozen_string_literal: true

require_relative "../lib/admin_constraint"

Rails.application.routes.draw do
  scope :admin, constraints: AdminConstraint.new do
    mount GoodJob::Engine => "good_job"

    resources :settings, only: [:index, :update]
    get "/debug", to: "debug#index"
  end

  resource :profile, only: [:edit, :update]
  resource :password, only: [:update]

  get "/", to: "stories#index"
  get "/fever", to: "fever#index"
  post "/fever", to: "fever#update"
  get "/archive", to: "stories#archived"
  get "/feed/:feed_id", to: "feeds#show"
  post "/feeds", to: "feeds#create"
  get "/feeds", to: "feeds#index"
  delete "/feeds/:id", to: "feeds#destroy"
  put "/feeds/:id", to: "feeds#update"
  get "/feeds/:id/edit", to: "feeds#edit"
  get "/feeds/export", to: "exports#index"
  post "/feeds/import", to: "imports#create"
  get "/feeds/import", to: "imports#new"
  get "/feeds/new", to: "feeds#new"
  get "/heroku", to: "debug#heroku"
  post "/login", to: "sessions#create"
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  get "/news", to: "stories#index"
  post "/setup/password", to: "passwords#create"
  get "/setup/password", to: "passwords#new"
  get "/setup/tutorial", to: "tutorials#index"
  get "/starred", to: "stories#starred"
  put "/stories/:id", to: "stories#update"
  post "/stories/mark_all_as_read", to: "stories#mark_all_as_read"

  unless Rails.env.production?
    require_relative "../spec/javascript/test_controller"

    get "/test", to: "test#index"
    get "/spec/*splat", to: "test#spec"
    get "/vendor/js/*splat", to: "test#vendor"
    get "/vendor/css/*splat", to: "test#vendor"
  end
end
