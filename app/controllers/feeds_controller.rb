require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/add_new_feed"
require_relative "../commands/feeds/export_to_opml"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = FeedRepository.list

    erb :'feeds/index'
  end

  delete "/feeds/:feed_id" do
    FeedRepository.delete(params[:feed_id])

    status 200
  end

  get "/feeds/new" do
    erb :'feeds/add'
  end

  post "/feeds" do
    @feed_url = params[:feed_url]
    feed = AddNewFeed.add(@feed_url)

    if feed and feed.valid?
      FetchFeeds.enqueue([feed])

      flash[:success] = "We've added your new feed. Check back in a bit."
      redirect to("/")
    elsif feed
      flash.now[:error] = "You are already subscribed to this feed..."
      erb :'feeds/add'
    else
      flash.now[:error] = "We couldn't find that feed. Try again."
      erb :'feeds/add'
    end
  end

  get "/feeds/import" do
    erb :'feeds/import'
  end

  post "/feeds/import" do
    ImportFromOpml.import(params["opml_file"][:tempfile].read)

    redirect to("/setup/tutorial")
  end

  get "/feeds/export" do
    content_type :xml

    ExportToOpml.new(Feed.all).to_xml
  end
end
