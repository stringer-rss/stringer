require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/flash"
require "sinatra/contrib/all"
require "json"
require "i18n"

require_relative "app/helpers/authentication_helpers"
require_relative "app/repositories/user_repository"

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config/locales', '*.yml').to_s]

class Stringer < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"
    set :views, "app/views"
    set :public_dir, "app/public"

    enable :sessions
    set :session_secret, ENV["SECRET_TOKEN"] || "secret!"

    enable :logging

    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
    register Sinatra::Contrib
  end

  helpers do
    include Sinatra::AuthenticationHelpers

    def render_partial(name, locals = {})
      erb "partials/_#{name}".to_sym, layout: false, locals: locals
    end

    def t(*args)
      I18n.t(*args)
    end
  end

  before do
    I18n.locale = ENV["LOCALE"].blank? ? :en : ENV["LOCALE"].to_sym

    if !is_authenticated? && needs_authentication?(request.path)
      redirect '/login'
    end
  end

  get "/" do
    if UserRepository.setup_complete?
      redirect to("/news")
    else
      redirect to("/setup/password")
    end
  end
end

require_relative "app/controllers/stories_controller"
require_relative "app/controllers/first_run_controller"
require_relative "app/controllers/sessions_controller"
require_relative "app/controllers/feeds_controller"

