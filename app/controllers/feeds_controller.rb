require_relative "../repositories/feed_repository"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = Feed.all

    erb :'feeds/index'
  end

  post "/delete_feed" do
    FeedRepository.delete(params[:feed_id])

    status 200
  end
end