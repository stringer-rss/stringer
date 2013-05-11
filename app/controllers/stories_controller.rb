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

  post "/mark_as_read" do
    story = StoryRepository.fetch(params[:story_id])
    story.is_read = true
    StoryRepository.save(story)
  end

  post "/mark_all_as_read" do
    MarkAllAsRead.new(params[:story_ids]).mark_as_read
    
    redirect to("/news")
  end
end