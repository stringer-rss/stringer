# frozen_string_literal: true

module MarkAsStarred
  def self.call(story_id)
    StoryRepository.fetch(story_id).update!(is_starred: true)
  end
end
