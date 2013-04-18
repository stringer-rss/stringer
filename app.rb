require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/flash"
require "sinatra/contrib/all"
require "json"

require_relative "app/helpers/authentication_helpers"

class Stringer < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"
    set :views, "app/views"
    set :public_dir, "app/public"

    enable :sessions
    set :session_secret, ENV["SECRET_TOKEN"] || "secret!"

    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
    register Sinatra::Contrib
  end

  helpers do
    include Sinatra::AuthenticationHelpers

    # allow for partials using this syntax
    # = render partial: :foo
    def render(*args)
      if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
        return erb "partials/_#{args.first[:partial]}".to_sym, :layout => false
      else
        super
      end
    end
  end

  before do
    if !is_authenticated? && needs_authentication?(request.path)
      redirect '/login'
    end
  end

  get "/" do
    redirect to("/news")
  end
end

require_relative "app/controllers/stories_controller"
require_relative "app/controllers/first_run_controller"
require_relative "app/controllers/sessions_controller"