# frozen_string_literal: true

module Feed::FindNewStories
  STORY_AGE_THRESHOLD_DAYS = 3

  def self.call(raw_feed, feed_id)
    recent = raw_feed.entries.reject { |story| too_old?(story) }
    existing_ids = StoryRepository.existing_entry_ids(recent.map(&:id), feed_id)

    recent.reject { |story| existing_ids.include?(story.id) }
  end

  def self.too_old?(story)
    max_age = Time.now - STORY_AGE_THRESHOLD_DAYS.days
    story.published && story.published < max_age
  end
end
