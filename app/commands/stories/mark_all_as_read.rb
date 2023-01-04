# frozen_string_literal: true

require_relative "../../repositories/story_repository"

class MarkAllAsRead
  def self.call(*args)
    new(*args).call
  end

  def initialize(story_ids, repository = StoryRepository)
    @story_ids = story_ids
    @repo = repository
  end

  def call
    @repo.fetch_by_ids(@story_ids).update_all(is_read: true)
  end
end
