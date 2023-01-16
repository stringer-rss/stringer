# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class Stringer < Sinatra::Base
  get "/news" do
    @unread_stories = StoryRepository.unread

    erb :index
  end
end
