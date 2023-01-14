# frozen_string_literal: true

class TutorialsController < ApplicationController
  def index
    if UserRepository.setup_complete?
      redirect_to("/news")
      return
    end

    FetchFeeds.enqueue(Feed.all)
    CompleteSetup.complete(current_user)

    @sample_stories = StoryRepository.samples
  end
end
