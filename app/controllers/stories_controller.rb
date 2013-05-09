require_relative "../repositories/story_repository"
require_relative "../commands/stories/mark_all_as_read"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread.page(params[:page]).per_page(15)

    erb :index
  end

  get "/read" do
    @read_stories = StoryRepository.read.page(params[:page]).per_page(15)

    erb :read
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