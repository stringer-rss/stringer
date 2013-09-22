require_relative "../repositories/story_repository"
require_relative "../commands/stories/mark_all_as_read"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread

    erb :index
  end

  get "/feed/:feed_id" do
    @feed = FeedRepository.fetch(params[:feed_id])

    @stories = StoryRepository.feed(params[:feed_id])
    @unread_stories = @stories.find_all {|story| !story.is_read }

    erb :feed
  end

  get "/archive" do
    @read_stories = StoryRepository.read(params[:page])

    erb :archive
  end

  get "/starred" do
    @starred_stories = StoryRepository.starred(params[:page])

    erb :starred
  end

  put "/stories/:id" do
    json_params = JSON.parse(request.body.read, symbolize_names: true)
    
    story = StoryRepository.fetch(params[:id])
    story.is_read = !!json_params[:is_read]
    story.keep_unread = !!json_params[:keep_unread]
    story.is_starred = !!json_params[:is_starred]

    StoryRepository.save(story)
  end

  post "/stories/mark_all_as_read" do
    MarkAllAsRead.new(params[:story_ids]).mark_as_read
    
    redirect to("/news")
  end
end
