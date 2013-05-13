require_relative "../repositories/story_repository"
require_relative "../commands/stories/mark_all_as_read"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread

    erb :index
  end

  get "/archive" do
    @read_stories = StoryRepository.read(params[:page])

    erb :archive
  end

  put "/stories/:id" do
    json_params = JSON.parse(request.body.read, symbolize_names: true)
    
    story = StoryRepository.fetch(params[:id])
    story.is_read = json_params[:is_read]
    story.keep_unread = json_params[:keep_unread]
    StoryRepository.save(story)
  end

  post "/mark_all_as_read" do
    MarkAllAsRead.new(params[:story_ids]).mark_as_read
    
    redirect to("/news")
  end
end