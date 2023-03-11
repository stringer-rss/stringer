# frozen_string_literal: true

module MarkAsUnstarred
  def self.call(story_id)
    StoryRepository.fetch(story_id).update!(is_starred: false)
  end
end
