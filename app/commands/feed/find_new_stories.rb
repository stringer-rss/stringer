# frozen_string_literal: true

module Feed::FindNewStories
  STORY_AGE_THRESHOLD_DAYS = 3

  def self.call(raw_feed, feed_id, latest_entry_id = nil)
    stories = []

    raw_feed.entries.each do |story|
      break if latest_entry_id && story.id == latest_entry_id
      next if story_age_exceeds_threshold?(story) || StoryRepository.exists?(
        story.id,
        feed_id
      )

      stories << story
    end

    stories
  end

  def self.story_age_exceeds_threshold?(story)
    max_age = Time.now - STORY_AGE_THRESHOLD_DAYS.days
    story.published && story.published < max_age
  end
end
