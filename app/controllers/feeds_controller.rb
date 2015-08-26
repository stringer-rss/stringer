require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/add_new_feed"
require_relative "../commands/feeds/export_to_opml"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = FeedRepository.list

    erb :'feeds/index'
  end

  get "/feeds/:id/edit" do
    @feed = FeedRepository.fetch(params[:id])

    erb :'feeds/edit'
  end

  put "/feeds/:id" do
    feed = FeedRepository.fetch(params[:id])

    FeedRepository.update_feed(feed, params[:feed_name], params[:feed_url])

    flash[:success] = t('feeds.edit.flash.updated_successfully')
    redirect to('/feeds')
  end

  delete "/feeds/:feed_id" do
    FeedRepository.delete(params[:feed_id])

    status 200
  end

  get "/feeds/new" do
    @feed_url = params[:feed_url]
    erb :'feeds/add'
  end

  post "/feeds" do
    @feed_url = params[:feed_url]
    feed = AddNewFeed.add(@feed_url)

    if feed and feed.valid?
      FetchFeeds.enqueue([feed])

      flash[:success] = t('feeds.add.flash.added_successfully')
      redirect to("/")
    elsif feed
      flash.now[:error] = t('feeds.add.flash.already_subscribed_error')
      erb :'feeds/add'
    else
      flash.now[:error] = t('feeds.add.flash.feed_not_found_error')
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
    content_type 'application/xml'
    attachment 'stringer.opml'

    ExportToOpml.new(Feed.all).to_xml
  end
end
