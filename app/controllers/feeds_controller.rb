require_relative "../repositories/feed_repository"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = Feed.all
    
    erb :'feeds/index'
  end
end