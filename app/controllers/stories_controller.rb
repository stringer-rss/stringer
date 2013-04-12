require_relative "../repositories/story_repository"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread

    erb :index
  end

  post "/mark_as_read" do
    story = StoryRepository.fetch(params[:story_id])
    story.is_read = true
    StoryRepository.save(story)
  end
end