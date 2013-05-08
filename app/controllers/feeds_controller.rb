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
    feed = AddNewFeed.add(params[:feed_url])

    if feed
      FetchFeeds.enqueue([feed])

      flash[:success] = "We've added your new feed. Check back in a bit."
      redirect to("/")
    else
      flash.now[:error] = "We couldn't find that feed. Try again."
      erb :'feeds/add'
    end
  end

  get "/import" do
    erb :import
  end

  post "/import" do
    ImportFromOpml.import(params["opml_file"][:tempfile].read, true)

    redirect to("/setup/tutorial")
  end

  get "/export" do
    content_type :xml

    ExportToOpml.new(Feed.all).to_xml
  end
end
