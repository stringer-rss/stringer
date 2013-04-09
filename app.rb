require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/flash"
require "sinatra/contrib/all"

require_relative "app/models/feed"
require_relative "app/models/story"

class Stringer < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"
    set :views, "app/views"
    set :public_dir, "app/public"

    enable :sessions
    set :session_secret, "secret!"

    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
    register Sinatra::Contrib
  end

  helpers do
    # allow for partials using this syntax
    # = render partial: :foo
    def render(*args)
      if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
        return haml "partials/_#{args.first[:partial]}".to_sym, :layout => false
      else
        super
      end
    end
  end

  get "/" do
    @stories = Story.all

    erb :index
  end
end