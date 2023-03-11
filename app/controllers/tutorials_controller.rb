# frozen_string_literal: true

class TutorialsController < ApplicationController
  def index
    authorization.skip
    CallableJob.perform_later(Feed::FetchAllForUser, current_user)

    @sample_stories = StoryRepository.samples
  end
end
