# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread

    erb :index
  end

  get "/feed/:feed_id" do
    @feed = FeedRepository.fetch(params[:feed_id])

    @stories = StoryRepository.feed(params[:feed_id])
    @unread_stories = @stories.reject(&:is_read)

    erb :feed
  end
end
