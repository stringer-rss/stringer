require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/add_new_feed"
require_relative "../commands/feeds/export_to_opml"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = FeedRepository.list

    erb :'feeds/index'
  end

  delete "/feeds/:feed_id" do
    
    # unsubscribe to superfeedr
    begin
      unless settings.superfeedr.nil?
        feed = FeedRepository.fetch(params[:feed_id])
        settings.superfeedr.unsubscribe(feed.url)
      end
    rescue Exception => msg  
      puts msg
    end 
    #

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

      # subscribe to superfeedr
      begin
        unless settings.superfeedr.nil?
          subscription = settings.superfeedr.subscribe(feed.url)
          if !subscription
            flash.now[:error] = t('feeds.add.flash.superfeedr_subscribe_error')
            erb :'feeds/add'
          end
        end 
      rescue Exception => msg  
        #puts msg
        flash.now[:error] = t('feeds.add.flash.superfeedr_subscribe_error')
        erb :'feeds/add'
      end 
      #
      
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
    content_type :xml

    ExportToOpml.new(Feed.all).to_xml
  end
end
