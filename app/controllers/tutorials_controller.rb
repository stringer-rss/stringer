# frozen_string_literal: true

class TutorialsController < ApplicationController
  def index
    FetchFeeds.enqueue(Feed.all)

    @sample_stories = StoryRepository.samples
  end
end
