require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/flash"
require "sinatra/contrib/all"

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
    @stories = []
    @stories << Story.new("The GitHub Blog", "New GitHub Pages domain: github.io", "Beginning today all GitHub pages...")
    @stories << Story.new("Quantified Self", "Eric Boyd: Learning from my Nike FuelBand Data", "We've been getting some...")
    @stories << Story.new("Atomic Spin", "Why Mou Is My New Note-Taking App", "Taking notes has been a part...")
    @stories << Story.new("FlowingData", "Introducing Data Points", "Whoa, that was fast. Data...")
    
    erb :index
  end

  class Story < Struct.new(:source, :headline, :lead); end;
end